select *
from PortfolioProject..NashvilleHousing


--Standardizing the date format
select SaleDate
from PortfolioProject..NashvilleHousing

--update NashvilleHousing
--set SaleDate = cast(SaleDate as date)

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

select SaleDate, SaleDateConverted
from PortfolioProject..NashvilleHousing


--Populating Property Address Data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.UniqueID, a.ParcelID, a.PropertyAddress, b.UniqueID, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
	on  a.ParcelID = b.ParcelID 
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
	on  a.ParcelID = b.ParcelID 
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


--Breaking Address into different columns(Address, City, State)

select PropertyAddress
from PortfolioProject..NashvilleHousing

select PropertyAddress, substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))
from PortfolioProject..NashvilleHousing


alter table NashvilleHousing
add Address nvarchar(255);

update NashvilleHousing
set Address = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


alter table NashvilleHousing
add City nvarchar(255);

update NashvilleHousing
set City = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

select *
from PortfolioProject..NashvilleHousing

--update NashvilleHousing
--set Address = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

EXEC sp_rename 'NashvilleHousing.PropertySplitAddresss', 'PropertySplitAddress', 'COLUMN';
EXEC sp_rename 'NashvilleHousing.City', 'PropertySplitCity', 'COLUMN';


select OwnerAddress,
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)


alter table NashvilleHousing
add OwnerSpiltCity nvarchar(255);

update NashvilleHousing
set OwnerSpiltCity = parsename(replace(OwnerAddress, ',', '.'), 2)


alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)


--Changing Y and N to 'Yes' and 'No' in 'Sold as Vacant' field


select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2 desc

select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant 
end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant 
    end


--Removing Duplicates


with cte as
(select *,
row_number() over(partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference order by UniqueID) as rnk
from PortfolioProject..NashvilleHousing)

delete
from cte
where rnk > 1


--Deleting Unused Columns


select *
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
drop column SaleDate, PropertyAddress, OwnerAddress, TaxDistrict