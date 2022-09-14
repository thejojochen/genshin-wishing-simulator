// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "./VRFv2Consumer.sol";
import "./genshinCharacterFactory.sol";

//wish object, three parameters (kind of a generic name (item) though)
/*is VRFv2Consumer*/
contract Wish {
    struct Item {
        string weaponOrCharacter;
        string name;
        uint256 rarity;
    }

    bool public initialized;

    //to do: group variables into initialized and dynamic, add mapping player => dynamic variable

    //initizlied variables, can be changed by admin
    //Item[] public listOfItems;
    Item[] public threeStarListOfItems;
    Item[] public fourStarListOfItems;
    Item[] public featuredFourStarListOfItems;
    Item[] public fiveStarListOfItems;
    Item public featuredFiveStar = Item("g", "g", 5); //make sure to add functionality for a second banner

    //uint256 randomNumber = 5800;
    //make sure to add functionality for a second banner/

    //player specific variables
    uint256 public fiveStarWishCounter = 0;
    uint256 public fourStarWishCounter = 0;
    //bools potentially less gas effecient
    bool public fiveStarFiftyFifty = false;
    bool public fourStarFiftyFifty = false;
    uint256 public playerPrimogemAmount = 160;
    Item[] public itemsWon;

    //target VRF consumer
    //VRFv2Consumer public targetVrfContract;

    //target factory
    genshinCharacterFactory public targetFactory =
        genshinCharacterFactory(0xdC8468BF0d020587E4a010D886b6B96CE59c88f8);

    //intialize VRF consumer (probably not, we will inherit from vrfv2consumer)
    constructor(address _factoryAddr) {
        targetFactory = genshinCharacterFactory(_factoryAddr);
    }

    ///////////////////////////////////////////
    ///////////////testing only////////////////
    ///////////////////////////////////////////

    function setFiveStarWishCounter(uint256 _counter) public returns (uint256) {
        fiveStarWishCounter = _counter;
        return fiveStarWishCounter;
    }

    function setFourStarWishCounter(uint256 _counter) public returns (uint256) {
        fourStarWishCounter = _counter;
        return fourStarWishCounter;
    }

    ///////////////////////////////////////////
    ///////////////testing only////////////////
    ///////////////////////////////////////////

    // function createItem(
    //     string memory weaponOrCharacter,
    //     string memory name,
    //     uint256 rarity
    // ) public {
    //     listOfItems.push(Item(weaponOrCharacter, name, rarity));
    // }

    function createThreeStarItem(
        string memory weaponOrCharacter,
        string memory name,
        uint256 rarity
    ) public {
        threeStarListOfItems.push(Item(weaponOrCharacter, name, rarity));
    }

    function createFourStarItem(
        string memory weaponOrCharacter,
        string memory name,
        uint256 rarity
    ) public {
        fourStarListOfItems.push(Item(weaponOrCharacter, name, rarity));
    }

    function createFeaturedFourStarItem(
        string memory weaponOrCharacter,
        string memory name,
        uint256 rarity
    ) public {
        featuredFourStarListOfItems.push(Item(weaponOrCharacter, name, rarity));
    }

    function createFiveStarItem(
        string memory weaponOrCharacter,
        string memory name,
        uint256 rarity
    ) public {
        fiveStarListOfItems.push(Item(weaponOrCharacter, name, rarity));
    }

    // function getRandomNumber() public view returns (uint256) {
    //     return targetContract.s_randomWords(0);
    // }

    function executeWishLogic(
        uint256 _randomNumber1, /*this number needs to be modded*/
        uint256 _randomNumber2,
        address _to,
        uint256 featuredFiveStarIndex
    ) public returns (bool) {
        require(_randomNumber1 >= 1 && _randomNumber1 <= 100000);

        fiveStarWishCounter++;
        fourStarWishCounter++;

        if (fiveStarWishCounter >= 90) {
            determineFiveStar(
                _randomNumber1,
                _randomNumber2,
                _to,
                featuredFiveStarIndex
            );
            fiveStarWishCounter = 0;
            fourStarWishCounter = 0;
            return true;
        } else {
            if (fourStarWishCounter % 10 == 0 && fourStarWishCounter != 0) {
                determineFourStar(_randomNumber1);
                fourStarWishCounter = 0;
                return true;
            } else {
                if (_randomNumber1 > 5700) {
                    uint256 index = _randomNumber1 % getThreeStarListLength();

                    pushWonItem(index, threeStarListOfItems);
                    return true;
                } else {
                    if (_randomNumber1 > 600 && _randomNumber1 <= 5700) {
                        determineFourStar(_randomNumber1);
                        fourStarWishCounter = 0;
                        return true;
                    } else {
                        if (_randomNumber1 <= 600) {
                            determineFiveStar(
                                _randomNumber1,
                                _randomNumber2,
                                _to,
                                featuredFiveStarIndex
                            );
                            fiveStarWishCounter = 0;
                            fourStarWishCounter = 0;
                            return true;
                        } else {
                            revert();
                        }
                    }
                }
            }
        }
    }

    //uri indexes of standar five stars
    uint256[] public standardFiveStars;

    function setStandardFiveStars(uint256[] memory indexesToAdd) public {
        for (uint i = 0; i < indexesToAdd.length; i++) {
            standardFiveStars.push(indexesToAdd[i]);
        }
    }

    function determineFiveStar(
        uint256 _randomNumber1,
        uint256 _randomNumber2,
        address _to,
        uint256 _URIIndex
    ) internal {
        if (_randomNumber1 % 2 == 0 || fiveStarFiftyFifty == true) {
            fiveStarFiftyFifty = false;
            fourStarFiftyFifty = false;

            targetFactory.mintFeaturedFiveStar(_to, _URIIndex);
        } else {
            fiveStarFiftyFifty = true;
            //uint256 index = _randomNumber2 % getFiveStarListLength();

            targetFactory.mintRandomItem(
                standardFiveStars,
                _to,
                _randomNumber2
            );
        }
    }

    function determineFourStar(uint256 _randomNumber) internal {
        if (_randomNumber % 2 == 0 || fourStarFiftyFifty == true) {
            fourStarFiftyFifty = false;
            uint256 index = _randomNumber % getFeaturedFourStarListLength();

            pushWonItem(index, featuredFourStarListOfItems);
        } else {
            fourStarFiftyFifty = true;
            uint256 index = _randomNumber % getFourStarListLength();

            pushWonItem(index, fourStarListOfItems);
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

    ////////////////////
    //getter functions
    ////////////////////

    function getThreeStarListLength() public view returns (uint256) {
        return threeStarListOfItems.length;
    }

    function getFourStarListLength() public view returns (uint256) {
        return fourStarListOfItems.length;
    }

    function getFeaturedFourStarListLength() public view returns (uint256) {
        return featuredFourStarListOfItems.length;
    }

    function getFiveStarListLength() public view returns (uint256) {
        return fiveStarListOfItems.length;
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

    function viewFourStarItemList(uint256 index)
        public
        view
        returns (string memory)
    {
        Item memory temp = fourStarListOfItems[index];
        string memory name = temp.name;
        return name;
    }

    function viewFeaturedFourStarItemList(uint256 index)
        public
        view
        returns (string memory)
    {
        Item memory temp = featuredFourStarListOfItems[index];
        string memory name = temp.name;
        return name;
    }

    function viewFiveStarItemList(uint256 index)
        public
        view
        returns (string memory)
    {
        Item memory temp = fiveStarListOfItems[index];
        string memory name = temp.name;
        return name;
    }
}
