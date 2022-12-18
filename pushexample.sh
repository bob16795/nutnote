pushd example
zip example.zip * -r
popd

butler push example/example.zip prestosilver/nutnote:example
