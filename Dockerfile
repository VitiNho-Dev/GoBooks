# Build do código Go
FROM golang:latest AS builder

# Configuração do diretório de trabalho dentro do container
WORKDIR /app

# Copia os arquivos go.mod e go.sum e realiza o download das dependências
COPY go.mod go.sum ./
RUN go mod download

# Copia o código fonte da API para dentro do container
COPY . .

# Compila o código Go em um executável binário compatível com Linux
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -o api ./cmd/gobook/main.go

# Usa uma imagem oficial do Ubuntu como base
FROM ubuntu:latest

# Instala o SQLite3
RUN apt-get update && apt-get install -y sqlite3

# Configuração do diretório de trabalho na nova imagem
WORKDIR /app

# Copia o binário da API do container builder
COPY --from=builder /app/api .

# Cria o arquivo de banco de dados SQLite
RUN sqlite3 /app/books.db "CREATE TABLE IF NOT EXISTS books ( id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, author TEXT NOT NULL, genre TEXT NOT NULL );"

# Expõe a porta 8080 para o Google Cloud Run
EXPOSE 8080

# Define o comando de inicialização do container
CMD ["./api"]
