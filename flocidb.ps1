# Ajusta el endpoint 
$endpoint = "http://localhost:4566"
$region   = "us-east-1"
$tabla = "tabla-polizas"

# 0. Limpieza previa

aws dynamodb describe-table --table-name $TABLA --endpoint-url $ENDPOINT --region $region *> $null
if ($LASTEXITCODE -eq 0) {
    aws dynamodb delete-table --table-name $TABLA --endpoint-url $ENDPOINT --region $region | Out-Null
    Write-Host "Tabla existente eliminada."
} else {
    Write-Host "No existe tabla previa."
}

# 1. Crear la base
aws dynamodb create-table `
  --table-name $tabla `
  --attribute-definitions AttributeName=numeroPoliza,AttributeType=S AttributeName=version,AttributeType=N `
  --key-schema AttributeName=numeroPoliza,KeyType=HASH AttributeName=version,KeyType=RANGE `
  --billing-mode PAY_PER_REQUEST `
  --endpoint-url $ENDPOINT `
  --region $region

  # 2. Verificar que se creo la base
  aws dynamodb list-tables --endpoint-url $ENDPOINT --region $region
  aws dynamodb describe-table --table-name $tabla --endpoint-url $ENDPOINT

  # 3. Insertar Items
aws dynamodb put-item --table-name tabla-polizas `
  --item "numeroPoliza={S=POL-001},version={N=1},cliente={S='Juan Pérez'},estado={S=ACTIVA},prima={N=250.50}" `
  --endpoint-url $ENDPOINT `
  --region $region

  aws dynamodb put-item --table-name tabla-polizas `
  --item "numeroPoliza={S=POL-001},version={N=2},cliente={S='Juan Pérez'},estado={S=BAJA},prima={N=280.00}" `
  --endpoint-url $ENDPOINT `
  --region $region

  # Leer
  aws dynamodb get-item --table-name tabla-polizas `
  --key "numeroPoliza={S=POL-001},version={N=1}" `
  --endpoint-url $ENDPOINT `
  --region $region

  # Query
  aws dynamodb query --table-name tabla-polizas `
  --key-condition-expression "numeroPoliza = :p" `
  --expression-attribute-values ":p={S=POL-001}" `
  --endpoint-url $ENDPOINT `
  --region $region

  # Update
  aws dynamodb update-item --table-name tabla-polizas `
  --key "numeroPoliza={S=POL-001},version={N=1}" `
  --update-expression "SET estado = :e" `
  --expression-attribute-values ":e={S=CANCELADA}" `
  --return-values ALL_NEW `
  --endpoint-url $ENDPOINT `
  --region $region

<#
  # Limpieza Tabla
  aws dynamodb delete-table --table-name $TABLA --endpoint-url $ENDPOINT   --region $region | Out-Null
  Write-Host "Tabla eliminada."

  #>