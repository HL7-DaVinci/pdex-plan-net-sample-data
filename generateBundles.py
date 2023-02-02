import os
import json
import sys
import getopt
from glob import glob

exampleFolderLocation = r""
outputLocation = r""
baseUrl = ""
recursive = False
httpVerb = ""

arg_help = "{0} -f <folder> -u <url> -o <output> -r <recursive> -v <verb>".format(sys.argv[0])

try:
    opts, args = getopt.getopt(sys.argv[1:], "hf:u:o:r:v:", ["help", "folder=",
                                                     "url=", "output=", "recursive=, verb="])
except:
    print(arg_help)
    sys.exit(2)

for opt, arg in opts:
    if opt in ("-h", "--help"):
        print(arg_help)  # print the help message
        sys.exit(2)
    elif opt in ("-f", "--folder"):
        exampleFolderLocation = arg
    elif opt in ("-u", "--url"):
        baseUrl = arg
    elif opt in ("-o", "--output"):
        outputLocation = arg
    elif opt in ("-r", "--recursive"):
        recursive = bool(arg)
    elif opt in ("-v", "--verb"):
            httpVerb = opt

if not outputLocation:
    outputLocation = os.getcwd()

if not baseUrl:
    baseUrl = "{{FHIR_BASE_URL}}"

if not exampleFolderLocation:
    print("Need to provide a directory with sample data")
    sys.exit(2)

if not httpVerb:
    httpVerb = "PUT"

#build entry list and returns list

def  build_entries(resources):
    entries = []
    #loop through resources, pull id and populate fullUrl and request:url
    for x in resources:
        loadedJsonDict = json.loads(x)
        id = loadedJsonDict["id"]
        resourceType = loadedJsonDict["resourceType"]
        entry = {
            "fullUrl": f"{baseUrl}/{resourceType}/{id}",
            "resource": loadedJsonDict,
            "request": {
                "method": "PUT",
                "url": f"{resourceType}/{id}"
            }
        }
        entries.append(entry)
    return entries

#loads resource into string and adds to list
def extractFiles(directory):
    resources = []
    for x in directory:
        f = str
        if not recursive:
            f = open(rf"{exampleFolderLocation}\{x}", encoding="utf8").read()
        else:
            f = open(rf"{x}", encoding="utf8").read()
        #resources.append(json.loads(f))
        resources.append(f)
    return resources

folder = list[str];

if not recursive:
  folder = os.listdir(exampleFolderLocation)
else:
  print('Recursive selected: getting files....')
  folder = [y for x in os.walk(exampleFolderLocation) for y in glob(os.path.join(x[0], '*.json'))]

resources = extractFiles(folder)
entries = build_entries(resources)

#example entries
"""
    {
      "fullUrl": "http://example.org/fhir/Patient/123",
      "resource": {
        "resourceType": "Patient",
        "id": "123",
        "text": {
          "status": "generated",
          "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">Some narrative</div>"
        },
        "active": true,
        "name": [
          {
            "use": "official",
            "family": "Chalmers",
            "given": [
              "Peter",
              "James"
            ]
          }
        ],
        "gender": "male",
        "birthDate": "1974-12-25"
      },
      "request": {
        "method": "PUT",
        "url": "Patient/123"
      }
    }
"""

requestBody = {
  "resourceType": "Bundle",
  "id": "bundle-transaction",
  "meta": {
    "lastUpdated": "2022-12-22T01:43:30Z"
  },
  "type": "transaction",
  "entry": entries
}

newFile = open(outputLocation,'w')
newFile.write(json.dumps(requestBody, indent = 4))
newFile.close()