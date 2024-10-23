# Dockerfile
# Use an official C++ build image
FROM gcc:latest

# Set the working directory
WORKDIR /app

# Copy the CMakeLists.txt and source files
COPY /Livox-SDK/CMakeLists.txt .
COPY /Livox-SDK/Doxyfile .
COPY /Livox-SDK/build ./build/
COPY /Livox-SDK/doc ./doc/
COPY /Livox-SDK/sample ./sample/
COPY /Livox-SDK/sample_cc ./sample_cc/
COPY /Livox-SDK/sdk_core ./sdk_core/

# Install CMake
RUN apt-get update && apt-get install -y cmake

# Build the application
WORKDIR /app/build
RUN cmake .. && make
