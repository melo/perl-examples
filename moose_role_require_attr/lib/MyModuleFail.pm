package MyModuleFail;

use Moose;

with 'MyModule::ProvideAttr', 'MyModule::RequireAttr';

no Moose;

1;
