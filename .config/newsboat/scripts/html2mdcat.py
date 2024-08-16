#!/usr/bin/env python3
import os
import random
import re
import string
import sys

from markdownify import markdownify as md


def main():
    with open(sys.argv[1], "r") as f:
        html = f.read()

    print(sys.argv[1])
    # yande.re or Konachan
    if "yande.re" in html or "konachan" in html:
        # will find sample image
        img = re.search(
            # r"https://(files\.yande\.re|konachan\.com)/(sample|image)/(.*?).jpg", html
            # r"Podcast Download URL: (.*?) ", html
            r"src=\"(.*?)\"", html
        )
        # try:
        #     print(f"Loading {img[0]}...")
        # except TypeError:
        #     img = re.search(r"https://(files\.yande\.re|konachan\.com)/image/(.*?).jpg", html)
        print(f"Loading {img[1]}...")
        os.system(
            f'kitty +kitten icat {img[1]} && read -p "Press any key... " -n1 -s && clear'
        )
        return

    re.search(r"Feed: (.*)", html)
    title = re.search(r"Title: (.*)", html)
    re.search(r"Author: (.*)", html)
    re.search(r"Date: (.*)", html)
    link = re.search(r"Link: (.*)", html).group(1)

    h = md(html, heading_style="ATX")
    # adding line break after image
    h = re.sub(
        r"[^[](!\[.*?\]\(.*?\))([^\n])",
        lambda match: match.group(1) + "\n\n" + match.group(2),
        h,
    )
    # adding line break before image
    h = re.sub(
        r"([^[\n])(!\[.*?\]\(.*?\))",
        lambda match: match.group(1) + "\n\n" + match.group(2),
        h,
    )
    # move image out of a link
    h = re.sub(r"(\[!\[\]\(.*?\)).*?\]", lambda match: match.group(1)[1:] + "[", h)
    # move image caption out
    h = re.sub(r"(!\[.*?)(\]\(.*?\))", lambda match: "![" + match.group(2), h)

    fname = f"/tmp/{randomword(10)}.md"
    # print(sys.argv[1])
    # print(fname)
    h = h.split("\n")
    with open(fname, "w") as f:
        f.write(f"# [{title.group(1)}]({link})\n\n")
        for line in h:
            if "Related" in line:
                break
            if line == "":
                continue
            f.write(line + "\n\n")

    os.system(
        f'mdcat --columns 80 {fname} && read -p "Press any key... " -n1 -s && clear'
    )


def randomword(length):
    letters = string.ascii_lowercase
    return "".join(random.choice(letters) for i in range(length))


if __name__ == "__main__":
    main()
