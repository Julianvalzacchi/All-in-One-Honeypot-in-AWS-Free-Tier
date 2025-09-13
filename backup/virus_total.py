import hashlib
from virus_total_apis import PublicApi

API_KEY = "245f62c6be1982c85f5cfeaa3b88ede712c431363246a2d052b0d18451189a1d"
api = PublicApi(API_KEY)

target_file_name = input("Por favor, introduce la ruta completa del archivo sospechoso: ")

try:
    with open(target_file_name, "rb") as file:
        file_hash = hashlib.md5(file.read()).hexdigest()
except FileNotFoundError:
    print(f"Error: El archivo '{target_file_name}' no se encontró en la ruta especificada.")
    exit()

response = api.get_file_report(file_hash)

if response["response_code"] == 200:
    if response["results"]["response_code"] == 1:
        if response["results"]["positives"] > 0:
            print("Archivo malicioso")
            print("Detalles de las detecciones:")
            for antivirus, detection_info in response["results"]["scans"].items():
                if detection_info["detected"]:
                    print(f"  - {antivirus}: {detection_info['result']}")
        else:
            print("Archivo seguro")
    elif response["results"]["response_code"] == 0:
        print(f"Archivo no analizado previamente por VirusTotal. Mensaje: {response['results']['verbose_msg']}")
    else:
        print(f"Error inesperado en el resultado del análisis: {response['results']['verbose_msg']}")
else:
    print(f"No ha podido obtenerse el análisis del archivo. Error de API: {response['verbose_msg']}")
