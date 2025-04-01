# Базовый образ для backend (Java + Spring Boot)
FROM eclipse-temurin:17-jdk AS backend

# Устанавливаем рабочую директорию
WORKDIR /p

# Копируем файлы проекта и собираем приложение
COPY backend/ .
RUN ./gradlew clean build bootJar -DskipTests

# Базовый образ для frontend (Angular)
FROM node:20 AS frontend

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы проекта и устанавливаем зависимости
COPY frontend/package.json frontend/package-lock.json ./
RUN npm install

# Копируем остальной код и собираем приложение
COPY frontend/ .
RUN npm run build

# Финальный образ для запуска
FROM eclipse-temurin:17-jre

# Создаем рабочую директорию
WORKDIR /app

# Копируем backend jar-файл
COPY --from=backend /p/build/libs/*.jar app.jar
# Копируем frontend билд
COPY --from=frontend /app/dist/frontend /app/static

# Открываем порт
EXPOSE 8080

# Команда запуска
ENTRYPOINT ["java", "-jar", "app.jar"]