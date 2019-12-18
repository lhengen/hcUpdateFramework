unit hcUpdateConsts;

interface


const
  ManifestFileName :string = 'Manifest.xml';
  AppDir :string = '{app}';
  PatchFileExtension :string = '.pth';

type
  UpdateResult = (urSuccess,urFailure);

const
  UpdateResultNames :array[UpdateResult] of string = ('Success','Failure');


implementation

end.
