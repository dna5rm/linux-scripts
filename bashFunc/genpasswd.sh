# Use python to generate a random password

function genpasswd ()
{
python3 << EOF
import random,string
length = int('''${1:-16}''')
chars = string.ascii_letters + string.digits + "!@#$%^&*()"
rnd = random.SystemRandom()
print("".join(rnd.choice(chars) for i in range(length)))
EOF
}
