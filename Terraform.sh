#!/bin/bash
curl https://www.terraform.io/downloads.html > output.txt

grep -i latest output.txt > output2.txt && defaulttfversion=$(grep -E -o "[0-9].[[0-9][0-9].[0-9]+[0-9]?" output2.txt | head -1)


rm output.txt output2.txt #CleanupFiles


defaulttfurl="https://releases.hashicorp.com/terraform/${defaulttfversion}/terraform_${defaulttfversion}_linux_amd64.zip"
defaulttfpath="/usr/local/bin/terraform"



checkpackage() {
    echo "Checking Installation Of $1"

    if ! command -v "$1" &> /dev/null
    then
        echo "$1 could not be found"
        echo "Installing $1"
        sudo dnf install "$1" -y
    else
        echo "$1 exists on the current system!"
    fi
}

installterraform() {
    wget "$defaulttfurl"
    unzip "terraform_${defaulttfversion}_linux_amd64.zip"
    sudo mv terraform "$defaulttfpath"
    rm terraform_${defaulttfversion}_linux_amd64.zip #Cleanup ZipFile

}

upgradeterraform() {
    echo "Checking for an out of date Terraform"

    if terraform -version | grep -q 'out of date'; then
       tfpath=$(which terraform)
       oldversion=$(terraform -version | grep 0 | grep -Eo '[0-9]+\.[0-9]+[0-9]+\.[0-9]+[0-9]?' | head -n1)
       newversion=$(terraform -version | grep 0 | grep -Eo '[0-9]+\.[0-9]+[0-9]+\.[0-9]+[0-9]?' | tail -n1)
       echo "Current Terraform Version is $oldversion. Upgrading to $newversion."
       wget "https://releases.hashicorp.com/terraform/${newversion}/terraform_${newversion}_linux_amd64.zip"
       unzip terraform_${newversion}_linux_amd64.zip
       sudo mv terraform "$tfpath"

       if command -v terraform &> /dev/null
       then
           echo "Successfully Upgraded"
       fi

       rm terraform_${newversion}_linux_amd64.zip #Cleanup ZipFile

    else
        echo "Terraform is already up to date!"
    fi
}

checkterraform() {
    if ! command -v terraform &> /dev/null
    then
        read -rp "Terraform is not installed on the system. Do you want to install Terraform? Yes/No : " varoption

        if [ -z "$varoption" ]
        then
            echo "Input cannot be blank please try again!"
            exit 0
        fi

        varoption=$(echo "$varoption" | tr "[:upper:]" "[:lower:]") 

        case "$varoption" in
        
          "yes")
            echo "Installing Terraform"
            checkpackage "wget"
            checkpackage "unzip"
            installterraform
            ;;
        
          "no")
            echo "Not installing Terraform"
            exit 0
            ;;
        
        
          *)
            echo "$varoption is not a valid option exiting the script"
            exit 1
            ;;
        esac
        
    else
        read -rp "Terraform is already installed. Do you want to upgrade Terraform? Yes/No : " varupgrade


        if [ -z "$varupgrade" ]
        then
            echo "Input cannot be blank please try again!"
            exit 0
        fi

        varupgrade=$(echo "$varupgrade" | tr "[:upper:]" "[:lower:]")

        case "$varupgrade" in

          "yes")
            echo "Upgrading Terraform"
            upgradeterraform
            ;;
        
          "no")
            echo "Not upgrading Terraform"
            exit 0
            ;;
        
          *)
            echo "$varupgrade is not a valid option exiting the script"
            exit 1
            ;;
        esac
    fi
}

checkterraform