import bioblend.galaxy

url = 'http://127.0.0.1:8090'
api_key = '05b3ecc1982a6e8b4458b7f40af8ecff'
tools = ["flag-remove-peaks"]
gi = bioblend.galaxy.GalaxyInstance(url, api_key)
gi.verify = False

for tool in tools:
    endpoint = "api/tools/{}/install_dependencies".format(tool)
    deps = gi.make_post_request("/".join((url, endpoint)), payload={'id': tool})
    for d in deps:
        print d


