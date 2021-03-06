include "build_support.boo"

solution = "MarkEmbling.PostcodesIO.sln"
configuration = "release"
test_assembly = "MarkEmbling.PostcodesIO.Tests/bin/${configuration}/MarkEmbling.PostcodesIO.Tests.dll"
bin_path = "build/bin"

target default, (compile, test, prep):
  pass

desc "Compiles the solution"
target compile:
  msbuild(file: solution, configuration: configuration, version: "4.0")

desc "Executes the tests"
target test, (compile):
  with nunit(assembly: test_assembly, toolPath: "packages/NUnit.Runners.2.6.4/tools/nunit-console.exe")
  
desc "Copies the binaries to the 'build/bin' directory"
target prep, (compile, test):
  rmdir(bin_path)
  
  with FileList("MarkEmbling.PostcodesIO/bin/${configuration}"):
    .Include("*.{dll,exe,config,nupkg}")
    .ForEach def(file):
      file.CopyToDirectory(bin_path)

desc "Publishes the NuGet packages"
target publish, (prep):
  api_key = read_nuget_api_key()
  
  with FileList(bin_path):
    .Include("*.nupkg")
    .ForEach def(file):
      filename = Path.GetFileName(file.FullName)
      if prompt("Publish ${filename}...?"):
        with nuget_push():
          .toolPath =  ".nuget/NuGet.exe"
          .packagePath = file.FullName
          .apiKey = api_key
