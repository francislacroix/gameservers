# Take the container account name and password as arguments
ACCOUNT_NAME=$1
ACCOUNT_PASSWORD=$2

# Step 1: Confirm that the script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please run with sudo or as the root user."
    exit 1
fi

# Step 2: Create the mount point
mkdir -p /mnt/serverbackups

# Step 3: Create the credentials directory if it doesn't exist
if [ ! -d "/etc/smbcredentials" ]; then
    mkdir /etc/smbcredentials
fi

# Step 4: Create the credentials file if it doesn't exist
if [ ! -f "/etc/smbcredentials/$ACCOUNT_NAME.cred" ]; then
    bash -c "echo \"username=$ACCOUNT_NAME\" >> /etc/smbcredentials/$ACCOUNT_NAME.cred"
    bash -c "echo \"password=$ACCOUNT_PASSWORD\" >> /etc/smbcredentials/$ACCOUNT_NAME.cred"
fi

# Step 5: Set the permissions for the credentials file
chmod 600 /etc/smbcredentials/$ACCOUNT_NAME.cred

# Step 6: Add the mount entry to /etc/fstab and mount the share
bash -c 'echo "//$ACCOUNT_NAME.file.core.windows.net/serverbackups /mnt/serverbackups cifs nofail,credentials=/etc/smbcredentials/$ACCOUNT_NAME.cred,dir_mode=0755,file_mode=0755,serverino,nosharesock,mfsymlinks,actimeo=30" >> /etc/fstab'
mount -t cifs //$ACCOUNT_NAME.file.core.windows.net/serverbackups /mnt/serverbackups -o credentials=/etc/smbcredentials/$ACCOUNT_NAME.cred,dir_mode=0755,file_mode=0755,serverino,nosharesock,mfsymlinks,actimeo=30