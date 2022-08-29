#!/bin/sh

. /usr/share/debconf/confmodule

set -e

# create a templates file with the strings for debconf to display
cat > /run/script.templates << 'EOF'
Template: script/progress/a
Type: text
Description: Step A

Template: script/progress/b
Type: text
Description: Step B

Template: script/progress/fallback
Type: text
Description: Running ${STEP}...
EOF

# use the utility to load the generated template file
debconf-loadtemplate script /run/script.templates

# pause just to show "Running Preseed..."
sleep 2

# foreach 3 steps tell debconf which template string to display
for step in a b c; do

    if ! db_progress INFO script/progress/$step; then
        db_subst script/progress/fallback STEP "$step"
        db_progress INFO script/progress/fallback
    fi

    case $step in
        "a")
            # run commands or scripts in the installer environment (this uses the sleep command in the installer environment)
            mkdir -p /home/user/Desktop/firstrun
            sleep 10
            ;;
        "b")
            # run commands or scripts in the chroot environment (this uses the sleep command from the installed system)
            mkdir -p /home/user/Desktop/firstrun
            in-target sleep 10
            ;;
        "c")
            # just another sample step
            mkdir -p /home/user/Desktop/firstrun
            sleep 10
            ;;
    esac
done
