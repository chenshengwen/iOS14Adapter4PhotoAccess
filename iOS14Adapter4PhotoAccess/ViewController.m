//
//

#import "ViewController.h"
#import <PhotosUI/PhotosUI.h>
#import "PickerVC.h"


@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate>
@property (nonatomic, assign) BOOL isDoing;

@property (nonatomic, strong) UIImagePickerController *picker;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.picker.delegate = self;
    self.picker.allowsEditing = NO;
    
}

#pragma mark - 单选

- (IBAction)openPickerAciton:(id)sender
{
    self.isDoing = NO;
    
    if (self.isDoing) {
        return;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO) {
        return;
    }
    self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.isDoing = YES;
    [self presentViewController:self.picker animated:YES completion:nil];
}
#pragma mark - ******** 多选


- (IBAction)openNewPicker:(id)sender
{
    //三种过滤类型
    PHPickerFilter *imagesFilter = PHPickerFilter.imagesFilter;
    PHPickerFilter *videosFilter = PHPickerFilter.videosFilter;
    PHPickerFilter *livePhotosFilter = PHPickerFilter.livePhotosFilter;

    PHPickerConfiguration *configuration = [[PHPickerConfiguration alloc] init];
    configuration.filter = [PHPickerFilter anyFilterMatchingSubfilters:@[imagesFilter]]; // 可配置查询用户相册中文件的类型，支持三种
    configuration.selectionLimit = 0; // 默认为1，为0为跟随系统上限
     
    PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}
#pragma mark - ******** 手动触发选择更多照片或取消选择以移除访问权限的界面

- (IBAction)openCamera:(id)sender
{
    [[PHPhotoLibrary sharedPhotoLibrary] presentLimitedLibraryPickerFromViewController:self];
}
// 显示允许访问的相册

- (IBAction)openCustomPicker:(id)sender
{
    PickerVC *picker = [PickerVC new];
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:picker];
    [self presentViewController:nv animated:YES completion:nil];
}
/**
 请求limited 权限
 */
- (IBAction)requestAuth:(id)sender
{
    
    // 请求权限，需注意 limited 权限在 accessLevel 为 readAndWrite 时生效
    PHAccessLevel level1 = PHAccessLevelAddOnly;// 仅允许添加照片
    PHAccessLevel level2 = PHAccessLevelReadWrite;// 允许访问照片，limitedLevel 必须为 readWrite
    [PHPhotoLibrary requestAuthorizationForAccessLevel:level2 handler:^(PHAuthorizationStatus status) {
      switch (status) {
          case PHAuthorizationStatusLimited:
              NSLog(@"limited");
              break;
          case PHAuthorizationStatusDenied:
              NSLog(@"denied");
              break;
          case PHAuthorizationStatusAuthorized:
              NSLog(@"authorized");
              break;
          default:
              break;
      }
    }];
}

- (IBAction)checkAuth:(id)sender
{
    PHAccessLevel level1 = PHAccessLevelAddOnly;// 仅允许添加照片
    PHAccessLevel level2 = PHAccessLevelReadWrite;// 允许访问照片，limitedLevel 必须为 readWrite
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:level2];//查询权限
      switch (status) {
          case PHAuthorizationStatusLimited:
              NSLog(@"limited");
              break;
          case PHAuthorizationStatusDenied:
              NSLog(@"denied");
              break;
          case PHAuthorizationStatusAuthorized:
              NSLog(@"authorized");
              break;
          default:
              break;
    }
}

#pragma mark -代理

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14)) {
    [picker dismissViewControllerAnimated:YES completion:nil];
     if (!results || !results.count) {
         return;
     }
     NSItemProvider *itemProvider = results.firstObject.itemProvider;
     if ([itemProvider canLoadObjectOfClass:UIImage.class]) {
         __weak typeof(self) weakSelf = self;
         //异步获取
         [itemProvider loadObjectOfClass:UIImage.class completionHandler:^(__kindof id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
             if ([object isKindOfClass:UIImage.class]) {
                 __strong typeof(self) strongSelf = weakSelf;
                 dispatch_async(dispatch_get_main_queue(), ^{
                     strongSelf.imageView.image = (UIImage *)object;
                 });
             }
         }];
     }
}
#pragma mark - 图片选择

- (UIImagePickerController *)picker
{
    if (!_picker) {
        _picker = [[UIImagePickerController alloc]init];
    }
    return _picker;
}


@end
