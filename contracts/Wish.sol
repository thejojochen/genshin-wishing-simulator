// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
//import "./consumer.sol";
import "./GenshinGachaFactory.sol";

//wish object, three parameters (kind of a generic name (item) though)
/*is VRFv2Consumer*/
contract Wish is VRFConsumerBaseV2, ConfirmedOwner {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);
    event BannerExecuted(address indexed sender, uint8 wishId);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
        uint256 wishId;
        address sender;
        uint8 wishBannerId;
    }

    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // The gas lane to use, which specifies the maximum gas price to bump to.

    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
    bytes32 keyHash =
        0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 1000000;

    // The default is 3, but you can set this higher.
    //change to upercase
    uint16 public constant requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    //change to uppercase
    uint32 public constant numWords = 2;

    /**
     * HARDCODED FOR GOERLI
     * COORDINATOR: 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D
     */

    //target factory
    GenshinGachaFactory public targetFactory;

    //indexes of the characters and items, can be changed by admin
    uint256[] public standardFiveStars;
    uint256[] public standardFourStars;
    uint256[] public featuredFourStars;
    uint256[] public standardThreeStars;

    //player specific variables
    mapping(address => uint) public fiveStarWishCounter;
    mapping(address => uint) public fourStarWishCounter;
    //bools potentially less gas effecient, but more understandable
    mapping(address => bool) public fiveStarFiftyFifty;
    mapping(address => bool) public fourStarFiftyFifty;

    //indexes of featured five stars
    uint256 public featuredFiveStarCharacterIndexOne;
    uint256 public featuredFiveStarCharacterIndexTwo;

    constructor(uint64 subscriptionId, address _factoryAddr)
        VRFConsumerBaseV2(0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed)
        ConfirmedOwner(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed
        );
        s_subscriptionId = subscriptionId;
        targetFactory = GenshinGachaFactory(_factoryAddr);
    }

    // Assumes the subscription is funded sufficiently.

    function requestRandomWords(uint8 _wishId)
        external
        onlyOwner // check imported module from chainlink
        returns (uint256 requestId)
    {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false,
            wishId: _wishId,
            sender: msg.sender,
            wishBannerId: _wishId
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        emit BannerExecuted(msg.sender, _wishId);
        return requestId;
    }

    //delete this and put them in fufillrandomwords, (in memory)
    // uint256 public moddedNumber;
    // uint256 public randomNumber;
    // address public sender;

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);

        RequestStatus memory request = s_requests[_requestId];

        //possible add functionality for ten pull
        uint256 moddedNumber = (request.randomWords[0] % 100000) + 1;
        uint256 randomNumber = request.randomWords[1];
        address sender = request.sender;

        if (request.wishBannerId == 1) {
            wishBanner1(moddedNumber, randomNumber, sender);
        } else if (request.wishBannerId == 2) {
            wishBanner2(moddedNumber, randomNumber, sender);
        }

        // wishBanner1(uint256 num1,  uint256 num2, address _to)
    }

    function getRequestStatus(uint256 _requestId)
        external
        view
        returns (bool fulfilled, uint256[] memory randomWords)
    {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    function addConsumer() external onlyOwner {
        // Add a consumer contract to the subscription.
        COORDINATOR.addConsumer(s_subscriptionId, address(this));
    }

    bool public initialized;

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

    //bad access control
    function setFeaturedFiveStars(uint256 first, uint256 second) public {
        featuredFiveStarCharacterIndexOne = first;
        featuredFiveStarCharacterIndexTwo = second;
    }

    /*work on this*/
    function wishBanner1(
        uint256 num1,
        uint256 num2,
        address _to
    ) public returns (bool) {
        require(
            executeWishLogic(num1, num2, _to, featuredFiveStarCharacterIndexOne)
        );

        return true;
    }

    function wishBanner2(
        uint256 num1,
        uint256 num2,
        address _to
    ) public returns (bool) {
        require(
            executeWishLogic(num1, num2, _to, featuredFiveStarCharacterIndexTwo)
        );
        return true;
    }

    /*make this function internal soon since there is a wrapper above*/
    function executeWishLogic(
        uint256 _randomNumber1, /*this number is modded*/
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
                    targetFactory.mintRandomItem(
                        standardThreeStars,
                        _to,
                        _randomNumber2
                    );

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

            targetFactory.mintRandomItem(
                featuredFourStars,
                _to,
                _randomNumber2
            );
        } else {
            fourStarFiftyFifty[_to] = true;

            targetFactory.mintRandomItem(
                standardFourStars,
                _to,
                _randomNumber2
            );
        }
    }

    // add getters of other arrays as well (done)
    function standardFiveStarsLength() public view returns (uint256) {
        return standardFiveStars.length;
    }

    function standardFourStarsLength() public view returns (uint256) {
        return standardFourStars.length;
    }

    function featuredFourStarsLength() public view returns (uint256) {
        return featuredFourStars.length;
    }

    function standardThreeStarsLength() public view returns (uint256) {
        return standardThreeStars.length;
    }

    //deletes all elements in the array first, then add the array of indexes

    function setStandardFiveStars(uint256[] memory indexesToAdd) public {
        for (uint i = 0; i < standardFiveStars.length; ++i) {
            standardFiveStars[i] = 0;
        }
        for (uint i = 0; i < indexesToAdd.length; i++) {
            standardFiveStars.push(indexesToAdd[i]);
        }
    }

    function setStandardFourStars(uint256[] memory indexesToAdd) public {
        for (uint i = 0; i < standardFourStars.length; ++i) {
            standardFourStars[i] = 0;
        }
        for (uint i = 0; i < indexesToAdd.length; i++) {
            standardFourStars.push(indexesToAdd[i]);
        }
    }

    function setFeaturedFourStars(uint256[] memory indexesToAdd) public {
        for (uint i = 0; i < featuredFourStars.length; ++i) {
            featuredFourStars[i] = 0;
        }
        for (uint i = 0; i < indexesToAdd.length; i++) {
            featuredFourStars.push(indexesToAdd[i]);
        }
    }

    function setStandardThreeStars(uint256[] memory indexesToAdd) public {
        for (uint i = 0; i < standardThreeStars.length; ++i) {
            standardThreeStars[i] = 0;
        }
        for (uint i = 0; i < indexesToAdd.length; i++) {
            standardThreeStars.push(indexesToAdd[i]);
        }
    }
}
