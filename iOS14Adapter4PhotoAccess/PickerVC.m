//
//

#import "PickerVC.h"
#import <PhotosUI/PhotosUI.h>

@interface PicerCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@end

@implementation PicerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

-(void)initView
{
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    imageview.backgroundColor = [UIColor clearColor];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    _iconImageView = imageview;
    [self.contentView addSubview:_iconImageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.iconImageView.frame = self.contentView.bounds;
}

@end

@interface PickerVC ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *photoArray;
@end

@implementation PickerVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"显示允许访问的图片";
    self.photoArray = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *assetCollection in assetCollections) {
            [self enumerateAssetsInAssetCollection:assetCollection original:YES];
        }
        
        PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        [self enumerateAssetsInAssetCollection:cameraRoll original:YES];
    });
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 1;
    flowLayout.minimumInteritemSpacing = 1;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    self.collectionView.backgroundView.backgroundColor = self.collectionView.backgroundColor;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:PicerCell.class forCellWithReuseIdentifier:NSStringFromClass(PicerCell.class)];
    [self.view addSubview:self.collectionView];
}

- (void)getThumbnailImages
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *assetCollection in assetCollections) {
            [self enumerateAssetsInAssetCollection:assetCollection original:NO];
        }
        PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        [self enumerateAssetsInAssetCollection:cameraRoll original:NO];
    });
}

/*  遍历相簿中的全部图片
*  @param assetCollection 相簿
*  @param original        是否要原图
*/
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original
{
   NSLog(@"相簿名:%@", assetCollection.localizedTitle);
   PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
   options.resizeMode = PHImageRequestOptionsResizeModeFast;
   options.synchronous = YES;
   PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
   for (PHAsset *asset in assets) {
       CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
       __weak typeof(self) weakSelf = self;
       [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
           NSLog(@"%@", result);
           if (result) {
               original ? [weakSelf.photoArray addObject:result] : [weakSelf.photoArray addObject:result];
           }
       }];
       dispatch_async(dispatch_get_main_queue(), ^{
           [weakSelf.collectionView reloadData];
       });
   }
}

#pragma mark - UICollectionViewDataSource

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(self.view.frame) / 4, CGRectGetWidth(self.view.frame) / 4);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *image = self.photoArray[indexPath.row];
    PicerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(PicerCell.class) forIndexPath:indexPath];
    cell.iconImageView.image = image;
    return cell;
}

@end
