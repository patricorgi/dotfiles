#!/usr/bin/env python3
import os
import re
import sys
import termios
import tty


# Function to get a single keypress on Unix-based systems
def get_keypress():
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        return sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)


def main():
    with open(sys.argv[1], "r") as f:
        html = f.read()
    if "yande.re" not in html and "konachan" not in html:
        return

    # match strings
    # img = re.search(r"src=\"(.*?)\"", html)[1] # works for rsshub feed
    img = re.search(
        r"(https://(files.yande.re|konachan.com)/(sample|image|jpeg)/\S+)",
        html)[1]
    try:
        link = re.search(r"(Link|链接).*(http.*?)\n", html)[2].strip()
    except Exception as e:
        print("Exception", e)
        print("sys.argv[1]", sys.argv[1])
        print("html", html)
        print(re.search(r"(Link|链接): (.*?)\n", html))
        sys.exit(1)

    print(f"Loading {img}...")
    # os.system(f"curl -s {img} | wezterm imgcat")
    os.system(f"curl -s {img} | kitty +kitten icat")

    # key for actions
    print("Press any key to continue...")
    key = get_keypress()
    print("key:", key)
    if key == "d":
        os.system(
            'osascript -e \'tell application "Keyboard Maestro Engine" to do script "5A3B8BC3-6A4C-48EE-BD72-44FB78C2E5AA" with parameter "'
            + link + "\"' &> /dev/null &")

    os.system("clear")


if __name__ == "__main__":
    main()
