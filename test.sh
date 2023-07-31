#!/bin/bash

# Clean Old Files
rm -rf kfd
rm -rf kfd_offsets

# Clone kfd repository with hidedock_hidehomebar_hidelsicons branch
git clone -b hidedock_hidehomebar_hidelsicons https://github.com/Lrdsnow/kfd

# Clone kfd_offsets repository
git clone https://github.com/Lrdsnow/kfd_offsets

# Set og folder
og=$PWD
echo $og
# Loop through subfolders in kfd_offsets
cd kfd_offsets
for base_folder in */; do
  cd "$base_folder"
  
  for sub_folder in */; do
    cd "$sub_folder"
    
    # Get the basefolder & subfolder name (e.g., "iPhone10,6/iOS_16.6b1/")
    basefolder_name=$(basename "$base_folder")
    subfolder_name=$(basename "$sub_folder")
    echo "Building KFD for $basefolder_name $subfolder_name"
    
    # Copy dynamic_offsets.h to kfd
    rm -f $og/kfd/kfd/libkfd/info/dynamic_offsets.h
    cp ./dynamic_info.h $og/kfd/kfd/libkfd/info/dynamic_offsets.h
    
    # Change t1sz_boot if incorrect
    if [[ $basefolder_name -ne "iPhone15,2" && $basefolder_name -ne "iPhone15,3" ]]; then
        sed -i '' 's/#define t1sz_boot (17ull)/#define t1sz_boot (25ull)/' $og/kfd/kfd/libkfd/info/static_info.h
    else
        sed -i '' 's/#define t1sz_boot (25ull)/#define t1sz_boot (17ull)/' $og/kfd/kfd/libkfd/info/static_info.h
    fi
    
    # Build the Xcode project
    cd "$og/kfd"
    xcodebuild -project kfd.xcodeproj CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
    
    # Make KFD ipa:
    echo "Making ipa..."
    mkdir -p ../Payload
    cp -r build/Release-iphoneos/kfd.app ../Payload/kfd.app
    cd "$og"
    zip -r "./${basefolder_name}/${subfolder_name}/kfd.zip" ./Payload
    mv "./${basefolder_name}/${subfolder_name}/kfd.zip" "./${basefolder_name}/${subfolder_name}/kfd.ipa"
    rm -rf ./Payload
    cd kfd_offsets
  done
  
  cd ..
done
