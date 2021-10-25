from functions import uniform_random_value as urv


def get_urandom(request):
    """
    Returns a uniformly distributed random number provided the
    bounds of the interval are passed as a JSON load of the
    request in the form:

        json_load = {"a": 1.123, "b": 2.345}

    The the number returned will be: x ∈ [a,b]

    :return: Dict
    """

    print("The request has entered...")
    request_json = request.get_json(silent=True)

    print(f"request = {request}")

    r = {}
    if request_json and ("a" in request_json):
        print("Correct parsing and parameter was in json...")
        r = request_json
    else:
        print("Something happened with the parsing...")
        r = {"a": 0, "b": 1}

    print(f"The JSON load has been read: {r}")
    return {"value": urv(r["a"], r["b"])}


########################
# Example of request:
########################
# import requests
# headers = {'Content-type': 'application/json'}
# region = "europe-west1"
# project_id = "innate-infusion-327910"
# cloud_function_name = "urandom-generator"
# cf_url = f"https://{region}-{project_id}.cloudfunctions.net/{cloud_function_name}"
# json_load = {"a": 10, "b": 11}
# r = requests.post(url=cf_url, json=json_load, headers=headers)

########################
# Equivalent with CURL
########################
# curl -X POST $URL -H "Content-Type:application/json"  -d '{"a":10, "b":12}'
