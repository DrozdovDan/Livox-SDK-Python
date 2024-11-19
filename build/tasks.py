from invoke import task
import invoke

def compile_python_module(cpp_name, extension_name):
    invoke.run(
        "g++ -O3 -Wall -shared -std=c++11 -fPIC "
        "`python3 -m pybind11 --includes` "
        "-I /usr/include/python3 -I .  "
        "{0} "
        "-o {1}`python3-config --extension-suffix` "
        "-L. -l livox_sdk -Wl,-rpath,.".format(cpp_name, extension_name)
    )

@task
def build_cpplib(ctx):
    """ Build the sdk_core cpp lib """
    invoke.run(
        "g++ -O3 -Wall -Werror -Wno-error=maybe-uninitialized-shared -std=c++11 -I sdk_core/src -I sdk_core/include -I sdk_core/include/third_party/spdlog -fPIC sdk_core/src/livox_sdk.cpp "
        "-o liblivoxsdk.so "
    )

@task
def build_cython(ctx):
    """ Build the cython extension module """
    print("Building Cython Module")
    # Run cython on the pyx file to create a .cpp file
    invoke.run("cython --cplus -3 pylivox.pyx -o pylivox.cpp")

    # Compile and link the cython wrapper library
    compile_python_module("pylivox.cpp", "pylivox")
    print("* Complete")

@task
def test(ctx):
    print("OK")


