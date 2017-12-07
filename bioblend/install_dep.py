import bioblend.galaxy

url = 'http://0.0.0.0:8888'
api_key = '3e3c3dcd24de016993a4a593187c2358'
tools = ["flag-remove-peaks", "cameradims"]
gi = bioblend.galaxy.GalaxyInstance(url, api_key)
gi.verify = False

for tool in tools:
    endpoint = "api/tools/{}/install_dependencies".format(tool)
    deps = gi.make_post_request("/".join((url, endpoint)), payload={'id': tool})
    for d in deps:
        print d


