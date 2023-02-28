/*

Cleaning Data using SQL

*/

SELECT *
FROM Housing..NashvilleHousing

 Standardizing the Date

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


----------------------------------------------------------------------------------------------------------------------------

---- Populate Property Address data

SELECT *
FROM Housing..NashvilleHousing
--WHERE PropertyAddress IS NULL	
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Housing..NashvilleHousing a
JOIN Housing..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Housing..NashvilleHousing a
JOIN Housing..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Housing..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS City
FROM Housing..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT * 
FROM Housing..NashvilleHousing

SELECT OwnerAddress
FROM Housing..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),1),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
FROM Housing..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Housing..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Housing..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END










