// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "./VRFv2Consumer.sol";

contract Wish {
    struct Item {
        string weaponOrCharacter;
        string name;
        uint256 rarity;
    }

    Item[] public listOfItems;
    Item[] public threeStarListOfItems; //can be fixed size
    Item[] public fourStarListOfItems;
    Item[] public featuredFourStarListOfItems; // can be fixed size
    Item[] public fiveStarListOfItems; //can be fixed size
    Item[] public itemsWon;

    uint256 randomNumber = 5800;
    Item public featuredFiveStar = Item("g", "g", 5);
    uint256 public fiveStarWishCounter = 0;
    uint256 public fourStarWishCounter = 0;
    bool public fiveStarFiftyFifty = false;
    bool public fourStarFiftyFifty = false;

    uint256 public playerPrimogemAmount = 160;

    VRFv2Consumer public targetContract;

    constructor(address _targetAddr) {
        targetContract = VRFv2Consumer(_targetAddr);
    }

    function createItem(
        string memory weaponOrCharacter,
        string memory name,
        uint256 rarity
    ) public {
        listOfItems.push(Item(weaponOrCharacter, name, rarity));
    }

    function createThreeStarItem(
        string memory weaponOrCharacter,
        string memory name,
        uint256 rarity
    ) public {
        threeStarListOfItems.push(Item(weaponOrCharacter, name, rarity));
    }

    function viewThreeStarItemList(uint256 index)
        public
        view
        returns (string memory)
    {
        Item memory temp = threeStarListOfItems[index];
        string memory name = temp.name;
        return name;
    }

    function createFeaturedFourStarItem(
        string memory weaponOrCharacter,
        string memory name,
        uint256 rarity
    ) public {
        featuredFourStarListOfItems.push(Item(weaponOrCharacter, name, rarity));
    }

    function createFourStarItem(
        string memory weaponOrCharacter,
        string memory name,
        uint256 rarity
    ) public {
        fourStarListOfItems.push(Item(weaponOrCharacter, name, rarity));
    }

    function createFiveStarItem(
        string memory weaponOrCharacter,
        string memory name,
        uint256 rarity
    ) public {
        fiveStarListOfItems.push(Item(weaponOrCharacter, name, rarity));
    }

    function getRandomNumber() public view returns (uint256) {
        return targetContract.s_randomWords(0);
    }

    function executeWishLogic(uint256 _randomNumber) public {
        fiveStarWishCounter++;
        fourStarWishCounter++;

        if (fiveStarWishCounter == 90) {
            determineFiveStar(_randomNumber);
            fiveStarWishCounter = 0;
            fourStarWishCounter = 0;
        } else {
            if (fourStarWishCounter % 10 == 0 && fourStarWishCounter != 0) {
                determineFourStar(_randomNumber);
                fourStarWishCounter = 0;
            } else {
                if (_randomNumber <= 600) {
                    determineFiveStar(_randomNumber);
                    fiveStarWishCounter = 0;
                    fourStarWishCounter = 0;
                } else {
                    if (_randomNumber > 600 && randomNumber <= 5700) {
                        determineFourStar(_randomNumber);
                        fourStarWishCounter = 0;
                    } else {
                        if (_randomNumber > 5700) {
                            uint256 index = (0);
                            //Item memory itemYouWon = fiveStarListOfItems[index];
                            //itemsWon.push(Item(itemYouWon.weaponOrCharacter,  itemYouWon.name,  itemYouWon.rarity));
                            pushWonItem(index, threeStarListOfItems);
                        }
                    }
                }
            }
        }
    }

    function determineFiveStar(uint256 _randomNumber) internal {
        if (_randomNumber % 2 == 0 || fiveStarFiftyFifty == true) {
            //itemsWon.push ... featured five star
            itemsWon.push(featuredFiveStar);
            fiveStarFiftyFifty = false;
            fourStarFiftyFifty = false;
        } else {
            //itemsWon.push ... random standard banner five star character (done)
            //CHANGE ARBRITARY NUMBER 3 to number of items in list (list.length)
            uint256 index = (0);
            //Item memory itemYouWon = fiveStarListOfItems[index];
            //itemsWon.push(Item(itemYouWon.weaponOrCharacter,  itemYouWon.name,  itemYouWon.rarity));
            pushWonItem(index, fiveStarListOfItems);
            fiveStarFiftyFifty = true;
        }
    }

    function determineFourStar(uint256 _randomNumber) internal {
        if (_randomNumber % 2 == 0 || fourStarFiftyFifty == true) {
            //itemsWon.push ... random featured four star
            //CHANGE ARBRITARY NUMBER 3
            uint256 index = (0);
            //Item memory itemYouWon = fourStarListOfItems[index];
            //itemsWon.push(Item(itemYouWon.weaponOrCharacter,  itemYouWon.name,  itemYouWon.rarity));
            pushWonItem(index, featuredFourStarListOfItems);
            fourStarFiftyFifty = false;
        } else {
            //itemsWon.push ... random standard banner four star character
            //CHANGE ARBRITARY NUMBER 3
            uint256 index = (0);
            //Item memory itemYouWon = fourStarListOfItems[index];
            //itemsWon.push(Item(itemYouWon.weaponOrCharacter,  itemYouWon.name,  itemYouWon.rarity));
            pushWonItem(index, fourStarListOfItems);
            fourStarFiftyFifty = true;
        }
    }

    function pushWonItem(uint256 index, Item[] memory xStarList) internal {
        Item memory itemYouWon = xStarList[index];
        itemsWon.push(
            Item(
                itemYouWon.weaponOrCharacter,
                itemYouWon.name,
                itemYouWon.rarity
            )
        );
    }

    function getThreeStarListLength() public view returns (uint256) {
        return threeStarListOfItems.length;
    }
}
