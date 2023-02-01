--Data Cleaning Project-Nashville housying
Select *
From NashvilleHousingProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- 1. Standardize Date Format


Select saleDate, CONVERT(Date,SaleDate) as SaleDateConverted
From NashvilleHousingProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--------------------------------------------------------------------------------------------------------------------------

-- 2. Populate Property Address data

Select *
From NashvilleHousingProject.dbo.NashvilleHousing
Where PropertyAddress is not null
order by ParcelID


-- filling the blank property address when it has same parcelID using self join (if parcell id same it means the property adress is must be same)
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) --(ISNULL) is if a.propertyadress is null then popolated (filling) it with b.propertyaddress
From NashvilleHousingProject.dbo.NashvilleHousing a
JOIN NashvilleHousingProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] --the unique id must be different
Where a.PropertyAddress is null

--applying the query above and update the table

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousingProject.dbo.NashvilleHousing a
JOIN NashvilleHousingProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousingProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

--seperating the values in property adress using SUBSTRINGG and CHARINDEX (the separator is ',')
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address		--display the value before ','
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address		--display the value after ','

From NashvilleHousingProject.dbo.NashvilleHousing



--add new column (PropertySplitAdress)
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )



--add new column (PropertySplitCity)
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


--see the new column
Select PropertyAddress, propertysplitcity,propertysplitaddress
From NashvilleHousingProject.dbo.NashvilleHousing




Select OwnerAddress
From  NashvilleHousingProject.dbo.NashvilleHousing

--Split delimate data on OwnerAdrees using PARSENAME function
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousingProject.dbo.NashvilleHousing


-- apllying the PARSENAME and insert it to new column

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


--see new column
Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From NashvilleHousingProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousingProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


--Using Case to Change 'Y' to 'Yes' and 'N' to 'NO'
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousingProject.dbo.NashvilleHousing

--Applying the case to Change 'Y' to 'Yes' and 'N' to 'NO' using UPDATE Function
Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					)  row_num

From NashvilleHousingProject.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1		--if row num>1 its a duplicate


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From NashvilleHousingProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousingProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

