# ====== STAGE 1 — Build avec Maven ======
FROM maven:3.9.5-eclipse-temurin-17 AS build

WORKDIR /app

# Copier pom.xml pour télécharger les dépendances
COPY pom.xml .
RUN mvn -q -e dependency:resolve

# Copier le reste du code source
COPY src ./src

# Générer le jar sans tests (Jenkins fera les tests)
RUN mvn -q -e -DskipTests clean package


# ====== STAGE 2 — Image finale (léger + rapide) ======
FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# Copier le jar depuis l'étape build
COPY --from=build /app/target/*.jar app.jar

# Spring Boot écoute par défaut sur 8080
EXPOSE 8080

# Commande principale
ENTRYPOINT ["java", "-jar", "app.jar"]

