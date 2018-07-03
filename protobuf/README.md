![logo](https://github.com/cunit/cunit/raw/master/art/logo.png)

# *Protobuf*

Google Protobufs are AMAZING - they provide awesome cross platorm models 
and messages plus plus plus...

Well - using them just got way easy

## Dependency to a project

in cunit.yml
```yaml
dependencies:
    protobuf: 3.1.0
```

_Cross compilation has been thoroughly tested too_

## As a Tool


in cunit.yml
```yaml
tools:
    protobuf: 3.1.0
```

in your cmake file
```cmake
# ADD THE TOOL
find_tool(Protobuf REQUIRED)

# FIND ALL SOURCE FILES
file(GLOB PROTO_SRC ${CMAKE_CURRENT_LIST_DIR}/*.proto)

# EXECUTE THE IMPORTED TOOL
PROTOC(${CMAKE_CURRENT_BINARY_DIR}/generated PROTO_CPP_SRC ${PROTO_SRC})

# PRINT THE OUTPUT
message("Protobuf Generated CPP files: ${PROTO_CPP_SRC}")
```
