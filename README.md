# 📍 GeoDiário

Aplicativo móvel desenvolvido em **Flutter/Dart** para registrar fotografias associadas automaticamente à **data**, ao **horário** e à **localização geográfica** (latitude/longitude) em que foram capturadas. Os registros são armazenados localmente com **SQLite** (biblioteca `sqflite`).

Atividade Prática – Desenvolvimento Mobile com Flutter.

---

## ✅ Funcionalidades implementadas

| Requisito | Descrição | Onde está |
|---|---|---|
| **RF01** – Captura de fotografia | Abre a câmera do dispositivo (`image_picker`) para fotografar. | `lib/services/photo_service.dart`, `lib/screens/novo_registro_screen.dart` |
| **RF02** – Informações do registro | Data/hora registradas automaticamente no momento da foto; latitude e longitude obtidas pelo GPS (`geolocator`); usuário informa título e descrição. | `lib/services/location_service.dart`, `lib/screens/novo_registro_screen.dart` |
| **RF03** – Armazenamento local | A foto é copiada para o diretório de documentos do app (`path_provider`) e o banco SQLite guarda o **caminho** da imagem e os demais dados. | `lib/database/database_helper.dart`, `lib/services/photo_service.dart` |
| **RF04** – Consulta dos registros | Tela inicial em formato de galeria (grade com 2 colunas), ordenada do mais recente para o mais antigo, com "puxar para atualizar". | `lib/screens/home_screen.dart`, `lib/widgets/registro_card.dart` |
| **RF05** – Visualização e exclusão | Ao tocar em um registro, mostra a foto (com zoom em tela cheia) e todas as informações. Permite excluir o registro do banco **e** o arquivo de imagem correspondente, com confirmação. | `lib/screens/detalhes_screen.dart` |

Outros detalhes:
- Tratamento de GPS desligado / permissão negada, com opção de tentar novamente ou salvar sem coordenadas.
- Validação do título (obrigatório).
- Operações CRUD implementadas: **inclusão**, **consulta** (todos / por id) e **exclusão**.

---

## 📦 Bibliotecas utilizadas

| Pacote | Uso |
|---|---|
| [`sqflite`](https://pub.dev/packages/sqflite) | Banco de dados SQLite local |
| [`path`](https://pub.dev/packages/path) | Montagem de caminhos de arquivos / banco |
| [`path_provider`](https://pub.dev/packages/path_provider) | Diretório de documentos do app para salvar as fotos |
| [`image_picker`](https://pub.dev/packages/image_picker) | Captura de fotos pela câmera |
| [`geolocator`](https://pub.dev/packages/geolocator) | Acesso ao GPS (latitude e longitude) e permissões de localização |
| [`intl`](https://pub.dev/packages/intl) | Formatação de data e hora (`dd/MM/yyyy HH:mm:ss`) |

---

## 🗄️ Estrutura da tabela SQLite

Banco: `geodiario.db` — Tabela: `registros`

```sql
CREATE TABLE registros (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  titulo       TEXT    NOT NULL,
  descricao    TEXT,
  caminho_foto TEXT    NOT NULL,   -- caminho do arquivo .jpg no armazenamento local
  data_hora    TEXT    NOT NULL,   -- ISO-8601 (ex.: 2026-11-13T14:30:52.000)
  latitude     REAL,
  longitude    REAL
);
```

| Coluna | Tipo | Descrição |
|---|---|---|
| `id` | INTEGER (PK, autoincremento) | Identificador do registro |
| `titulo` | TEXT | Título informado pelo usuário |
| `descricao` | TEXT | Breve descrição (opcional) |
| `caminho_foto` | TEXT | Caminho da fotografia salva no dispositivo |
| `data_hora` | TEXT | Data e hora da captura |
| `latitude` | REAL | Latitude obtida pelo GPS |
| `longitude` | REAL | Longitude obtida pelo GPS |

---

## 🗂️ Organização do código

```
lib/
├── main.dart                        # Ponto de entrada / tema
├── models/
│   └── registro.dart                # Modelo + conversão Map <-> objeto
├── database/
│   └── database_helper.dart         # Criação do banco e CRUD (sqflite)
├── services/
│   ├── location_service.dart        # GPS e permissões (geolocator)
│   └── photo_service.dart           # Câmera e arquivos de imagem
├── screens/
│   ├── home_screen.dart             # Galeria de registros (RF04)
│   ├── novo_registro_screen.dart    # Captura + formulário (RF01–RF03)
│   └── detalhes_screen.dart         # Visualização e exclusão (RF05)
├── widgets/
│   ├── registro_card.dart           # Card da galeria
│   └── info_tile.dart               # Linha de informação reutilizável
└── utils/
    └── formatters.dart              # Formatação de data e coordenadas
```

---

## ▶️ Como executar (Android Studio)

Pré-requisitos: **Flutter SDK** instalado e **Android Studio** com os plugins **Flutter** e **Dart**.

1. No Android Studio: **File → Open…** e selecione a pasta `geodiario`.
2. Clique em **Pub get** (ou execute `flutter pub get` no terminal).
3. Selecione um emulador ou celular Android e clique em **Run ▶**.

Ou pelo terminal:

```bash
flutter pub get
flutter run
```

> **Dica (emulador):** para testar o GPS, defina uma localização em *Extended Controls (⋯) → Location* e clique em **Set Location**. A câmera do emulador funciona com a cena virtual padrão.

---

## 📸 Capturas de tela

> _Adicionar aqui as capturas das telas principais (galeria, novo registro e detalhes)._

| Galeria | Novo registro | Detalhes |
|---|---|---|
| ![Galeria](screenshots/home.png) | ![Novo registro](screenshots/novo.png) | ![Detalhes](screenshots/detalhes.png) |
