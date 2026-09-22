# SENAI CheckIn — Registro de Ponto e Diário de Campo

App mobile em Flutter para a Situação de Aprendizagem do Módulo 5 (PPDM). Registra visitas/pontos em campo com foto, GPS e observações, salvando tudo em SQLite local.

## Funcionalidades

- Captura de foto via câmera nativa
- Obtenção de latitude/longitude via GPS
- Registro de data/hora, foto, coordenadas e observação
- Persistência local em SQLite
- Listagem de registros com miniatura da foto
- Detalhes de cada registro
- Confirmação sonora ao salvar
- Tratamento de permissões (câmera e localização) em tempo de execução

### Modelo de dados

| Campo          | Tipo   | Descrição                          |
|----------------|--------|-------------------------------------|
| id             | INT    | Chave primária (autoincrement)      |
| data_hora      | TEXT   | Data/hora do registro (ISO 8601)    |
| latitude       | REAL   | Latitude capturada via GPS          |
| longitude      | REAL   | Longitude capturada via GPS         |
| observacao     | TEXT   | Observação livre do usuário         |
| caminho_foto   | TEXT   | Caminho local da imagem capturada   |

## Tecnologias e pacotes

- Flutter / Dart
- `sqflite` — persistência local (SQLite)
- `image_picker` — captura de foto via câmera
- `geolocator` — obtenção de GPS
- `permission_handler` — gerenciamento de permissões em runtime
- `path_provider` — diretório local para armazenar as fotos

## Fluxo de teste

1. Abrir o app → tela de listagem de registros
2. Tocar em "Novo registro"
3. Conceder permissão de câmera → capturar foto
4. Conceder permissão de localização → obter latitude/longitude
5. Adicionar observação e salvar
6. Ouvir confirmação sonora
7. Verificar o novo registro na lista, com miniatura da foto


## Critérios de avaliação (Módulo 5)

| Critério                                  | Pontos |
|--------------------------------------------|--------|
| Funcionalidade do GPS e permissões          | 20     |
| Captura de imagem e uso da câmera           | 20     |
| Persistência em SQLite                      | 20     |
| Interface e experiência do usuário          | 20     |
| Qualidade da solução e apresentação         | 20     |
| **Total**                                   | **100**|

## Autores

Daniel e Igor — Curso Técnico em Desenvolvimento de Sistemas (SESI)
