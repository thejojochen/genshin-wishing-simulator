// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
//import "./VRFv2Consumer.sol";
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

    /*work on this*/
    //player specific variables
    mapping(address => uint) public fiveStarWishCounter;
    mapping(address => uint) public fourStarWishCounter;
    mapping(address => bool) public fiveStarFiftyFifty;
    mapping(address => bool) public fourStarFiftyFifty;
    // uint256 public fiveStarWishCounter = 0;
    // uint256 public fourStarWishCounter = 0;
    //bools potentially less gas effecient
    // bool public fiveStarFiftyFifty = false;
    // bool public fourStarFiftyFifty = false;

    //uint256 public playerPrimogemAmount = 160;
    //Item[] public itemsWon;

    //target VRF consumer
    //VRFv2Consumer public targetVrfContract;

    //target factory
    genshinCharacterFactory public targetFactory;

    // genshinCharacterFactory(0xdC8468BF0d020587E4a010D886b6B96CE59c88f8);

    //intialize VRF consumer (probably not, we will inherit from vrfv2consumer)
    constructor(address _factoryAddr) {
        targetFactory = genshinCharacterFactory(_factoryAddr);
    }

    ///////////////////////////////////////////
    ///////////////testing only////////////////
    ///////////////////////////////////////////

    function setFiveStarWishCounter(uint256 _counter)
        public
    /*returns (uint256)*/
    {
        //uint newCounter = fiveStarWishCounter[msg.sender];
        fiveStarWishCounter[msg.sender] = _counter;
        //return newCounter;
    }

    function setFourStarWishCounter(uint256 _counter) public {
        // uint newCounter = fourStarWishCounter[msg.sender];
        fourStarWishCounter[msg.sender] = _counter;
        //return newCounter;
    }

    ///////////////////////////////////////////
    ///////////////testing only////////////////
    ///////////////////////////////////////////

    uint256 public featuredFiveStarCharacterIndexOne;
    uint256 public featuredFiveStarCharacterIndexTwo;

    function setFeaturedFiveStars(uint256 first, uint256 second) public {
        featuredFiveStarCharacterIndexOne = first;
        featuredFiveStarCharacterIndexTwo = second;
    }

    /*work on this*/
    function wishBanner1(
        uint256 num1,
        uint256 num2,
        address _to
    ) public {
        require(
            executeWishLogic(num1, num2, _to, featuredFiveStarCharacterIndexOne)
        );
    }

    function wishBanner2(
        uint256 num1,
        uint256 num2,
        address _to
    ) public {
        require(
            executeWishLogic(num1, num2, _to, featuredFiveStarCharacterIndexTwo)
        );
    }

    /*make this function internal soon since there is a wrapper above*/
    function executeWishLogic(
        uint256 _randomNumber1, /*this number needs to be modded*/
        uint256 _randomNumber2,
        address _to,
        uint256 featuredFiveStarIndex
    ) public returns (bool) {
        require(_randomNumber1 >= 1 && _randomNumber1 <= 100000);

        fiveStarWishCounter[_to]++;
        fourStarWishCounter[_to]++;

        // if at five star pity
        if (fiveStarWishCounter[_to] >= 90) {
            determineFiveStar(
                _randomNumber1,
                _randomNumber2,
                _to,
                featuredFiveStarIndex /* make sure to set this dynamically */
            );
            fiveStarWishCounter[_to] = 0;
            fourStarWishCounter[_to] = 0;
            return true;
        } else {
            // if at four star pity
            if (
                fourStarWishCounter[_to] % 10 == 0 &&
                fourStarWishCounter[_to] != 0
            ) {
                determineFourStar(_randomNumber1, _randomNumber2, _to);
                fourStarWishCounter[_to] = 0;
                return true;
            } else {
                // most unlucky case, get a random three star item (hehe for all the magic guides)
                if (_randomNumber1 > 5700) {
                    //uint256 index = _randomNumber1 % getThreeStarListLength();
                    targetFactory.mintRandomItem(
                        standardThreeStars,
                        _to,
                        _randomNumber2
                    );
                    //pushWonItem(index, threeStarListOfItems);
                    return true;
                } else {
                    // got a four star before pity
                    if (_randomNumber1 > 600 && _randomNumber1 <= 5700) {
                        determineFourStar(_randomNumber1, _randomNumber2, _to);
                        fourStarWishCounter[_to] = 0;
                        return true;
                    } else {
                        // got a five star before pity
                        if (_randomNumber1 <= 600) {
                            determineFiveStar(
                                _randomNumber1,
                                _randomNumber2,
                                _to,
                                featuredFiveStarIndex
                            );
                            fiveStarWishCounter[_to] = 0;
                            fourStarWishCounter[_to] = 0;
                            return true;
                        } else {
                            revert();
                        }
                    }
                }
            }
        }
    }

    //uri indexes of all the types of items
    uint256[] public standardFiveStars;
    uint256[] public standardFourStars;
    uint256[] public featuredFourStars;
    uint256[] public standardThreeStars;

    function standardFiveStarsLength() public view returns (uint256) {
        return standardFiveStars.length;
    }

    //delete all elements in the array first

    function setStandardFiveStars(uint256[] memory indexesToAdd) public {
        for (uint i = 0; i < indexesToAdd.length; i++) {
            standardFiveStars.push(indexesToAdd[i]);
        }
    }

    function setStandardFourStars(uint256[] memory indexesToAdd) public {
        for (uint i = 0; i < indexesToAdd.length; i++) {
            standardFourStars.push(indexesToAdd[i]);
        }
    }

    function setFeaturedFourStars(uint256[] memory indexesToAdd) public {
        for (uint i = 0; i < indexesToAdd.length; i++) {
            featuredFourStars.push(indexesToAdd[i]);
        }
    }

    function setStandardThreeStars(uint256[] memory indexesToAdd) public {
        for (uint i = 0; i < indexesToAdd.length; i++) {
            standardThreeStars.push(indexesToAdd[i]);
        }
    }

    function determineFiveStar(
        uint256 _randomNumber1,
        uint256 _randomNumber2,
        address _to,
        uint256 _URIIndex
    ) internal {
        if (_randomNumber1 % 2 == 0 || fiveStarFiftyFifty[_to] == true) {
            fiveStarFiftyFifty[_to] = false;
            fourStarFiftyFifty[_to] = false;

            targetFactory.mintFeaturedFiveStar(_to, _URIIndex);
        } else {
            fiveStarFiftyFifty[_to] = true;
            //uint256 index = _randomNumber2 % getFiveStarListLength();

            targetFactory.mintRandomItem(
                standardFiveStars,
                _to,
                _randomNumber2
            );
        }
    }

    function determineFourStar(
        uint256 _randomNumber1,
        uint256 _randomNumber2,
        address _to
    ) internal {
        if (_randomNumber1 % 2 == 0 || fourStarFiftyFifty[_to] == true) {
            fourStarFiftyFifty[_to] = false;
            //uint256 index = _randomNumber % getFeaturedFourStarListLength();
            targetFactory.mintRandomItem(
                featuredFourStars,
                _to,
                _randomNumber2
            );

            //pushWonItem(index, featuredFourStarListOfItems);
        } else {
            fourStarFiftyFifty[_to] = true;
            //uint256 index = _randomNumber % getFourStarListLength();
            targetFactory.mintRandomItem(
                standardFourStars,
                _to,
                _randomNumber2
            );
            //pushWonItem(index, fourStarListOfItems);
        }
    }
}
