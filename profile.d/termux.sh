# Things to do if inside termux.
if type "termux-info" >/dev/null 2>&1; then

    export CARGO_BUILD_TARGET=aarch64-linux-android
    export CRYPTOGRAPHY_DONT_BUILD_RUST=1

    alias android_settings="am start -a android.intent.action.MAIN -n com.android.settings/.Settings"
    alias mplayer=termux-open
    alias startx="export DISPLAY=:0 PULSE_SERVER=tcp:127.0.0.1:4713 && ${HOME}/bin/rc_files/openbox/startx.sh"
    alias tts="termux-tts-speak -r 1.5"

    function kp_user()
    {
        jq -r '.[].UserName' <(kp.sh show "${1}") | termux-clipboard-set
    }

    function kp_pass() {
        jq -r '.[].Password' <(kp.sh show "${1}") | termux-clipboard-set
    }

fi
