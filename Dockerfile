# ----- STAGE 1 : Build Maven -----
FROM maven:3.9.5-eclipse-temurin-17 AS build

WORKDIR /app

# Copier pom.xml et télécharger les dépendances
COPY pom.xml .
RUN mvn -B dependency:resolve dependency:resolve-plugins

# Copier le code source et compiler
COPY src ./src
RUN mvn -B package -DskipTests=true


# ----- STAGE 2 : Run -----
FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# Copier le .jar généré dans l'étape précédente
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

# Commande d'exécution
ENTRYPOINT ["java", "-jar", "app.jar"]
