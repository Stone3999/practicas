# Climate App

## Descripción
Aplicación móvil desarrollada con el framework Flutter que sirve como práctica inicial para la configuración del entorno de desarrollo, la vinculación con el SDK de Android y el despliegue en emuladores o dispositivos físicos. La interfaz actual muestra un diseño estático de condiciones climáticas centrado en la región de Hawaii.

## Requisitos Previos
Flutter SDK (Channel stable)
Android SDK y Command-line Tools (versión de Android Toolchain activa)
Visual Studio Code o Android Studio con extensiones de Flutter y Dart

## Configuración e Instalación
Clonar este repositorio en tu máquina local.
Abrir la terminal en la raíz del proyecto y ejecutar el siguiente comando para descargar las dependencias necesarias: flutter pub get
Asegurarse de tener un dispositivo conectado o un emulador encendido mediante el comando: flutter devices

## Despliegue de la Aplicación
Para ejecutar el proyecto en modo de desarrollo y contar con las funciones de actualización en tiempo real, utiliza el siguiente comando en la terminal:
flutter run

## Resultados Esperados
Al iniciar la aplicación, el dispositivo desplegará una pantalla con una barra superior que contiene el texto del identificador de pruebas, seguido por la temperatura actual de 29 grados Celsius, el nombre de la ubicación (Hawaii) y un gráfico representativo de condiciones soleadas en la parte inferior. La aplicación responde de forma inmediata a los cambios del archivo principal mediante reinicios automáticos al guardar el documento.