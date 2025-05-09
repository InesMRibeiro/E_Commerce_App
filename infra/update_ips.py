import json
import subprocess
import re

# 1. Obter os outputs do Terraform em JSON
print("Lendo IPs com Terraform...")
output = subprocess.run(["terraform", "output", "-json"], cwd="infra", capture_output=True, text=True)
data = json.loads(output.stdout)

# 2. Extrair IPs necessários
frontend_ip = data["frontend-ip"]["value"]
database_ip = data["database-ip"]["value"]

print(f"Frontend IP: {frontend_ip}")
print(f"Database IP: {database_ip}")

# 3. Substituir no backend/app.py
app_path = "backend/app.py"
with open(app_path, "r") as f:
    content = f.read()

# Expressão que captura a linha com CORS
updated = re.sub(
    r'http://[\d.]+',
    f'http://{frontend_ip}',
    content
)

with open(app_path, "w") as f:
    f.write(updated)

print(" IP do frontend atualizado no app.py")

# 4. Substituir no backend/config.py
config_path = "backend/config.py"
with open(config_path, "r") as f:
    content = f.read()

updated = re.sub(r'postgresql://postgres:postgres@[\d.]+:5432/inapp_db',
                 f'postgresql://postgres:postgres@{database_ip}:5432/inapp_db',
                 content)

with open(config_path, "w") as f:
    f.write(updated)

print(" IP da base de dados atualizado no config.py")
