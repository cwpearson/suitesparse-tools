from html.parser import HTMLParser


in_kind = False
kind_match = False

kinds = [
    "2D/3D",
    "Acoustics Problem",
    "Materials Problem",
    "Structural Problem",
    "Computational Fluid Dynamics Problem",
    "Model Reduction Problem",
    "Semiconductor Device Problem",
    "Theoretical/Quantum Chemisty Problem",
    "Thermal Problem",
]

class MyHTMLParser(HTMLParser):
    def handle_starttag(self, tag, attrs):
        global in_kind
        global kind_match
        # print("Start tag:", tag)
        # for attr in attrs:
        #     print("     attr:", attr)
        if tag == "td":
            in_kind = False
            for attr in attrs:
                if "column-kind" in attr[1]:
                    in_kind = True

        if tag == "a":
            if kind_match:
                for attr in attrs:
                    if "href" in attr[0]:
                        url = attr[1]
                        if "MM" in url:
                            print(url)
                            kind_match = False

    def handle_endtag(self, tag):
        # print("Encountered an end tag :", tag)
        pass

    def handle_data(self, data):
        global kind_match
        global in_kind
        if in_kind:
            for needle in kinds:
                if needle in data:
                    # print(data)
                    kind_match = True

parser = MyHTMLParser()

with open("suitesparse-reals.html") as f:
    parser.feed(f.read())