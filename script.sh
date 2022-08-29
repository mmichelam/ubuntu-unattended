#!/bin/sh

. /usr/share/debconf/confmodule

set -e

# create a templates file with the strings for debconf to display
cat > /run/my_script.templates << 'EOF'
Template: my_script/progress/a
Type: text
Description: Step A

Template: my_script/progress/b
Type: text
Description: Step B

Template: my_script/progress/fallback
Type: text
Description: Running ${STEP}...
EOF

# use the utility to load the generated template file
debconf-loadtemplate my_script /run/my_script.templates

# pause just to show "Running Preseed..."
sleep 2

# foreach 3 steps tell debconf which template string to display
for step in a b c; do

    if ! db_progress INFO my_script/progress/$step; then
        db_subst my_script/progress/fallback STEP "$step"
        db_progress INFO my_script/progress/fallback
    fi

    case $step in
        "a")
            # run commands or scripts in the installer environment (this uses the sleep command in the installer environment)
            sleep 10
            ;;
        "b")
            # run commands or scripts in the chroot environment (this uses the sleep command from the installed system)
            in-target sleep 10
            ;;
        "c")
            # just another sample step
            sleep 10
            ;;
    esac
done
