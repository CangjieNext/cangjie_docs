@Derive[ToString]
@When[os == "Linux"] // Error, unexpected when conditional compilation directive
class A {}
