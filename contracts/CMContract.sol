pragma solidity ^0.4.0;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract CMContract {
    using SafeMath for uint256;

    address private creator; // the creator
    mapping(address => uint256) balances; // token
    mapping(string => bool) copyrights_keys; // keys for copyrights
    mapping(string => CopyRight) copyrights; // copyrights  {id_in_server : CopyRight}
    address private zero_address = 0x0000000000000000000000000000000000000000;

    // copy right
    struct CopyRight {
        string ipfs_address; //ipfs hash address
        string id_in_server; // id of this IP in internal server database
        string cp_hash; //
        mapping(address => bool) owners_keys;
        address[] owners_addresses;
        mapping(address => uint256) owners_integer;
        mapping(address => uint256) owners_decimals;
    }

    // init
    function CMContract() public {
        creator = msg.sender;
    }

    // update a copyright
    function update_copyright(string ipfs_address, string id_in_server,string cp_hash, address owner, uint256 share_integer, uint256 share_decimals) public returns (bool) {

        CopyRight storage cp = copyrights[id_in_server];
        cp.ipfs_address = ipfs_address;
        cp.id_in_server = id_in_server;
        cp.cp_hash = cp_hash;

        if (copyrights_keys[id_in_server] == false) {
            // new ip
            cp.owners_keys[owner] = true;
            cp.owners_addresses.push(owner);
            cp.owners_integer[owner] = share_integer;
            cp.owners_decimals[owner] = share_decimals;

            copyrights_keys[id_in_server] = true;

        } else {

            // if owner exits
            if (cp.owners_keys[owner] == true) {
                // update share
                cp.owners_integer[owner] = share_integer;
                cp.owners_decimals[owner] = share_decimals;
                if (share_integer == 0 && share_decimals == 0) {
                    cp.owners_keys[owner] = false;
                }
            } else {
                // push a new owner
                cp.owners_keys[owner] = true;
                cp.owners_addresses.push(owner);
                cp.owners_integer[owner] = share_integer;
                cp.owners_decimals[owner] = share_decimals;
            }
        }
        return true;
    }

    // delete a copyright
    function delete_copyright(string id_in_server) public returns (bool){
        if (copyrights_keys[id_in_server] == true) {
            copyrights_keys[id_in_server] = false;
        }
        return true;
    }

    // id_in_server : id of this IP in internal server database
    function get_copyright_share(string id_in_server, address owner) public view returns (uint256, uint256, bool) {
        if (copyrights_keys[id_in_server] == true) {
            CopyRight storage cp = copyrights[id_in_server];
            if (cp.owners_keys[owner] == true) {
                return (cp.owners_integer[owner], cp.owners_decimals[owner],true);
            } else {
                return (0,0,true);
            }
        } else {
            return (0,0,false);
        }
    }

    // get balance
    function balance_of(address _user) public view returns (uint256 balance) {
        return balances[_user];
    }
    // transfer token from a to b
    function transfer(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        // SafeMath.sub will throw if there is not enough balance.
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        return true;
    }

    // *** only creator can use the functions below ***
    // generate token for users
    function generate_token (address _to, uint256 _value) public returns (bool) {
        require(msg.sender == creator);
        balances[_to] = balances[_to].add(_value);
        return true;
    }

    // *** tools ***
    // string a equal to string b ？
    function string_equal_to(string _a, string _b) private pure returns (bool) {
        if (keccak256(_a) == keccak256(_b)) {
            return true;
        }
        return false;
    }
}
