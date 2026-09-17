#!/usr/bin/env python3
"""
F5 BIG-IP Configuration Parser

This script extracts and displays F5 BIG-IP virtual server configurations
and their associated objects from UCS backup files. It supports configurations
across multiple partitions and handles various object types including pools,
nodes, profiles, and monitors.

Usage:
    ./f5_ucs_parser.py <ucs_file> <virtual_server_name> [--debug]

Example:
    ./f5_ucs_parser.py backup.ucs my_virtual_server_443_vs --debug
"""

import argparse
import tarfile
import re
from pathlib import Path
from collections import defaultdict

class F5ConfigParser:
    """
    Parser for F5 BIG-IP configuration files from UCS archives.

    This class handles the extraction and parsing of F5 BIG-IP configurations,
    including virtual servers and their associated objects from UCS backup files.

    Attributes:
        config_content (str): Combined configuration content from all config files.
            Includes both main configuration and partition-specific configurations.

        processed_objects (set): Set of processed configuration object names to
            prevent duplicate processing and infinite recursion.

        config_blocks (defaultdict): Dictionary storing parsed configuration blocks
            organized by object type. Keys are object types (e.g., 'Virtual Server',
            'Pool', 'Node') and values are lists of configuration blocks.

        debug (bool): Flag to enable debug output. When True, detailed processing
            information is printed to stdout.

    Methods:
        extract_config_from_ucs: Extracts configurations from UCS archive
        process_virtual_server: Processes virtual server and related configs
        extract_references: Extracts object references from config blocks
        get_config_block: Retrieves specific configuration blocks
        list_available_partitions: Lists all available partitions
    """
    def __init__(self, debug=False):
        self.config_content = ""
        self.processed_objects = set()
        self.config_blocks = defaultdict(list)
        self.debug = debug

    def debug_print(self, message):
        """
        Print debug messages when debug mode is enabled.

        Provides consistent formatting for debug output messages and only
        prints when debug mode is enabled.

        Args:
            message (str): Debug message to print

        Note:
            Debug messages are prefixed with 'DEBUG: ' for easy identification
            in the output stream.
        """
        if self.debug:
            print(f"DEBUG: {message}")

    def list_available_partitions(self):
        """
        List all available partitions in the configuration.

        Scans the configuration to identify all unique partitions that contain
        virtual server configurations.

        Returns:
            list: Sorted list of partition names (without leading '/')

        Example:
            ['Common', 'Partition1', 'Partition2']

        Note:
            This method only identifies partitions that contain virtual servers.
            Other partitions might exist but won't be listed if they don't
            contain virtual server configurations.
        """
        partitions = set()
        for line in self.config_content.splitlines():
            if 'ltm virtual /' in line:
                partition = line.split('/')[1]
                partitions.add(partition)
        return sorted(list(partitions))

    def list_virtual_servers(self):
        """
        List all virtual servers in the configuration.

        Returns:
            list: Sorted list of virtual server names with their full paths

        Example:
            [
                '/Common/app1_443_vs',
                '/Common/app2_80_vs',
                '/Partition1/app3_443_vs'
            ]

        Note:
            Virtual servers are returned with their full partition path.
        """
        virtuals = []
        for line in self.config_content.splitlines():
            if line.startswith('ltm virtual '):
                # Extract virtual server name with partition
                match = re.search(r'ltm virtual (/[^/]+/[^\s{]+)', line)
                if match:
                    virtuals.append(match.group(1))
        return sorted(virtuals)

    def extract_pool_members_and_monitors(self, pool_config):
        """
        Extract node references and monitors from pool configuration.

        Parses a pool configuration block to identify all pool members (nodes)
        and associated health monitors.

        Args:
            pool_config (str): Pool configuration block to parse

        Returns:
            list: List of tuples containing (object_type, object_name) where:
                - object_type can be 'node' or 'monitor'
                - object_name includes the full path with partition

        Example:
            For a pool config with two nodes and one monitor:
            [
                ('node', '/Common/node1'),
                ('node', '/Common/node2'),
                ('monitor', '/Common/http')
            ]
        """
        references = []

        if not pool_config:
            return references

        # Extract members with partition awareness
        members_match = re.search(r'members\s*{([^}]*(?:}[^}]*)*)}', pool_config, re.DOTALL)
        if members_match:
            member_content = members_match.group(1)
            self.debug_print(f"Processing members section:\n{member_content}")

            # Use regex to find all member entries
            member_pattern = r'/([^/]+)/([^:]+):(\d+)'
            member_matches = re.finditer(member_pattern, member_content)

            for match in member_matches:
                partition = match.group(1)
                node_name = match.group(2)
                node_ref = f"/{partition}/{node_name}"
                self.debug_print(f"Adding node reference: {node_ref}")
                references.append(('node', node_ref))

        # Extract monitors
        monitor_match = re.search(r'monitor\s+(/[^/]+/[^\s]+)', pool_config)
        if monitor_match:
            monitor = monitor_match.group(1)
            self.debug_print(f"Found monitor: {monitor}")
            references.append(('monitor', monitor))

        self.debug_print(f"Total node references found: {len([r for r in references if r[0] == 'node'])}")
        return references

    def extract_references(self, config_block):
        """
        Extract all referenced objects from a configuration block.

        Identifies and extracts references to various F5 objects including:
        - Profiles (HTTP, TCP, SSL, etc.)
        - Pools
        - Virtual addresses
        - Persistence profiles

        Args:
            config_block (str): Configuration block to parse

        Returns:
            list: List of tuples containing (object_type, object_name)
        """
        if not config_block:
            return []

        references = []

        # Extract profiles section
        profiles_section = re.search(r'profiles\s*{(.*?)\n    }', config_block, re.DOTALL)
        if profiles_section:
            profiles_content = profiles_section.group(1)
            self.debug_print(f"Raw profiles section:\n{profiles_content}")

            # Process each line in the profiles section
            current_profile = None
            for line in profiles_content.splitlines():
                line = line.strip()
                if not line:
                    continue

                # Extract profile name
                profile_match = re.match(r'/[^/]+/[^\s{]+', line)
                if profile_match:
                    current_profile = profile_match.group(0)
                    self.debug_print(f"Found profile: {current_profile}")
                    if current_profile not in [ref[1] for ref in references]:
                        references.append(('profile', current_profile))

        # Extract pool
        pool_match = re.search(r'pool\s+(/[^/]+/[^\s]+)', config_block)
        if pool_match:
            pool_name = pool_match.group(1)
            self.debug_print(f"Found pool: {pool_name}")
            references.append(('pool', pool_name))

        # Extract virtual address
        dest_match = re.search(r'destination\s+(/[^/]+/[^:]+)', config_block)
        if dest_match:
            vip_address = dest_match.group(1)
            self.debug_print(f"Found virtual address: {vip_address}")
            references.append(('virtual-address', vip_address))

        # Extract persistence profiles
        persist_section = re.search(r'persist\s*{([^}]+)}', config_block, re.DOTALL)
        if persist_section:
            persist_content = persist_section.group(1)
            persist_profiles = re.findall(r'/[^/]+/[^\s{]+', persist_content)
            for profile in persist_profiles:
                self.debug_print(f"Found persistence profile: {profile}")
                references.append(('profile', profile))

        self.debug_print(f"Total references found: {len(references)}")
        return references

    def get_profile_type(self, profile_name):
        """
        Determine the specific profile type based on the configuration.

        Analyzes the configuration to determine the exact type of a profile
        (client-ssl, http, tcp, analytics, or persistence).

        Args:
            profile_name (str): Name of the profile to analyze

        Returns:
            str: Specific profile type or 'profile' if type cannot be determined

        Profile Types:
            - client-ssl: SSL/TLS client-side profiles
            - http: HTTP protocol profiles
            - tcp: TCP protocol profiles
            - analytics: Analytics profiles
            - persistence: Session persistence profiles
        """
        profile_types = [
            ('client-ssl', r'profile client-ssl'),
            ('http', r'profile http'),
            ('tcp', r'profile tcp'),
            ('analytics', r'profile analytics'),
            ('persistence', r'persistence'),
        ]

        lines = self.config_content.splitlines()
        for line in lines:
            if profile_name in line:
                for p_type, pattern in profile_types:
                    if re.search(pattern, line):
                        return p_type
        return 'profile'

    def get_config_block(self, object_name, object_type=None):
        """
        Extract a complete configuration block for a specified object.

        Searches for and extracts the complete configuration block for a given
        object name and type. Handles both partition-prefixed and non-prefixed
        object names.

        Args:
            object_name (str): Name of the object to find (with or without partition prefix)
            object_type (str, optional): Type of object ('profile', 'pool', 'virtual', etc.)

        Returns:
            str or None: Complete configuration block if found, None otherwise

        Note:
            When object_name doesn't include a partition prefix, the method will:
            1. First try to find the object in any partition
            2. Then try the exact name as provided
            3. Return None if no matching configuration is found
        """
        if not object_name:
            return None

        # If no partition specified, try to find it
        if not object_name.startswith('/'):
            # Search pattern for virtual servers
            pattern = f'ltm virtual [^ ]*/[^/]+/{object_name}'
            matches = re.findall(pattern, self.config_content, re.MULTILINE)
            if matches:
                # Use the first match
                object_name = matches[0].split()[-1]
                self.debug_print(f"Found full virtual server name: {object_name}")

        # Now search for the config block
        lines = self.config_content.splitlines()
        block_lines = []
        in_block = False
        brace_count = 0

        for line in lines:
            if not in_block:
                if object_type == 'profile':
                    if re.search(f"^ltm (profile|persistence) [^ ]+ {re.escape(object_name)} {{$", line):
                        in_block = True
                        brace_count = 1
                        block_lines.append(line)
                else:
                    if re.search(f"^ltm .* {re.escape(object_name)} {{$", line):
                        in_block = True
                        brace_count = 1
                        block_lines.append(line)
            else:
                block_lines.append(line)
                brace_count += line.count('{')
                brace_count -= line.count('}')

                if brace_count == 0:
                    break

        return '\n'.join(block_lines) if block_lines else None

    def process_virtual_server(self, vs_name):
        """
        Process virtual server and its referenced objects.

        Extracts the virtual server configuration and all associated objects
        including pools, nodes, profiles, monitors, and persistence profiles.

        Args:
            vs_name (str): Name of the virtual server (with or without partition prefix)

        Note:
            If vs_name is provided without a partition prefix, the method will
            search for the virtual server in all available partitions.
        """
        vs_config = self.get_config_block(vs_name, 'virtual')
        if not vs_config:
            print(f"Could not find virtual server: {vs_name}")
            return

        self.config_blocks['Virtual Server'] = [vs_config]
        processed_configs = set()

        # Extract and process all references
        references = self.extract_references(vs_config)
        self.debug_print(f"Found references: {references}")

        # Process all references
        for ref_type, ref_name in references:
            if ref_name not in processed_configs:
                ref_config = self.get_config_block(ref_name, ref_type)
                if ref_config:
                    processed_configs.add(ref_name)
                    if ref_type.title() not in self.config_blocks:
                        self.config_blocks[ref_type.title()] = []
                    self.config_blocks[ref_type.title()].append(ref_config)
                    self.debug_print(f"Added {ref_type} config for: {ref_name}")

        # Process pool references separately
        for ref_type, ref_name in references:
            if ref_type == 'pool':
                pool_config = self.get_config_block(ref_name, 'pool')
                if pool_config:
                    self.config_blocks['Pool'] = [pool_config]
                    pool_refs = self.extract_pool_members_and_monitors(pool_config)

                    for pool_ref_type, pool_ref_name in pool_refs:
                        if pool_ref_name not in processed_configs:
                            pool_ref_config = self.get_config_block(pool_ref_name, pool_ref_type)
                            if pool_ref_config:
                                processed_configs.add(pool_ref_name)
                                if pool_ref_type.title() not in self.config_blocks:
                                    self.config_blocks[pool_ref_type.title()] = []
                                self.config_blocks[pool_ref_type.title()].append(pool_ref_config)

    def extract_config_from_ucs(self, ucs_path):
        """
        Extract configurations from all partition files in UCS archive.

        Reads and combines configurations from the main bigip.conf and all
        partition-specific configuration files found in the UCS archive.

        Args:
            ucs_path (str): Path to the UCS archive file

        Returns:
            bool: True if extraction was successful, False otherwise

        Note:
            Combines configurations in the following order:
            1. Main configuration (config/bigip.conf)
            2. Partition-specific configurations (config/partitions/*/bigip.conf)
        """
        try:
            with tarfile.open(ucs_path, 'r:*') as tar:
                # List all files in the tarball
                self.debug_print("Files in UCS archive:")
                for member in tar.getmembers():
                    self.debug_print(f"  {member.name}")

                config_content = []

                # Get main config
                main_config = tar.extractfile('config/bigip.conf')
                if main_config:
                    main_content = main_config.read().decode('utf-8')
                    config_content.append("# Begin config/bigip.conf")
                    config_content.append(main_content)
                    config_content.append("# End config/bigip.conf")

                # Get partition configs
                partition_configs = [
                    member for member in tar.getmembers()
                    if member.name.startswith('config/partitions/')
                    and member.name.endswith('/bigip.conf')
                ]

                self.debug_print("\nProcessing partition configs:")
                for config_file in partition_configs:
                    self.debug_print(f"  Reading {config_file.name}")
                    partition_content = tar.extractfile(config_file).read().decode('utf-8')
                    config_content.append(f"\n# Begin {config_file.name}")
                    config_content.append(partition_content)
                    config_content.append(f"# End {config_file.name}")

                # Combine all configs
                self.config_content = '\n'.join(config_content)

                # Debug: Show all virtual servers found
                self.debug_print("\nVirtual servers found:")
                virtuals = re.findall(r'^ltm virtual ([^\n]+)', self.config_content, re.MULTILINE)
                for virtual in virtuals:
                    self.debug_print(f"  {virtual}")

                return True
        except Exception as e:
            print(f"Error extracting config: {e}")
            return False

def main():
    """
    Main entry point for the F5 configuration parser.
    """
    parser = argparse.ArgumentParser(
        description='''
        Extract and display F5 BIG-IP virtual server configurations from UCS files.

        This tool parses F5 BIG-IP UCS (User Configuration Set) backup files and
        displays the configuration for a specified virtual server along with all
        its associated objects (pools, nodes, profiles, monitors, etc.).
        ''',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument('ucs_file',
                       help='Path to the UCS backup file to parse')
    parser.add_argument('vs_name',
                       nargs='?',  # Make vs_name optional
                       help='Name of the virtual server (with or without partition prefix)')
    parser.add_argument('--debug',
                       action='store_true',
                       help='Enable debug output for troubleshooting')
    parser.add_argument('--list-vips',
                       action='store_true',
                       help='List all virtual servers in the UCS file')
    parser.add_argument('--list-partitions',
                       action='store_true',
                       help='List all partitions in the UCS file')

    args = parser.parse_args()

    # Validate arguments
    if not args.vs_name and not (args.list_vips or args.list_partitions):
        parser.error("Either provide a virtual server name or use --list-vips or --list-partitions")

    if args.vs_name and (args.list_vips or args.list_partitions):
        parser.error("Cannot specify virtual server name with --list-vips or --list-partitions")

    f5_parser = F5ConfigParser(debug=args.debug)
    if not f5_parser.extract_config_from_ucs(args.ucs_file):
        print("Error: Could not extract configuration from UCS file")
        return

    if args.list_partitions:
        print("\nAvailable partitions:")
        for partition in f5_parser.list_available_partitions():
            print(f"  {partition}")
        return

    if args.list_vips:
        print("\nAvailable virtual servers:")
        for vip in f5_parser.list_virtual_servers():
            print(f"  {vip}")
        return

    f5_parser.process_virtual_server(args.vs_name)

    # Print configurations
    for config_type, configs in sorted(f5_parser.config_blocks.items()):
        if configs:  # Only print if there are configs
            print("#" * 60)
            print(f"### {config_type}")
            print("#" * 60)
            if isinstance(configs, list):
                for config in configs:
                    print(config)
                    print()
            else:
                print(configs)
                print()

if __name__ == "__main__":
    main()
