// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
//import "@tableland/contracts/TablelandTables.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; No hace falta, ya la jala otro contrato
import "./Child.sol";

contract Factory is ERC721Holder, Ownable {
    /* ITablelandTables internal _tableland; // */

    // Variables Tabla Comunidades
    string internal tableNameCom; //Complete Name of the Table
    uint256 internal _tableIdCom; //Id of the table on TableLand
    uint256 internal _counterCom; //Counter for the if of the communities

    Child[] public communitiesInContract;

    address internal _registry = 0x4b48841d4b32C4650E4ABc117A03FE8B51f38F68; //Polygon Mumbai

    event ChildCreated(address child);

    constructor() payable {
        /* _tableland = ITablelandTables(_registry); */
        _counterCom = 1000; //we initialize the counter
    }

    // Verifica que no se haya creado la tabla
    modifier tableExist(uint256 idtable) {
        bool exist = false;

        if (idtable != 0) exist = true;

        require(!exist, "This table has already been created");
        _;
    }

    //Creation of the table for store the communities
    /* function createTableCom() external payable tableExist(_tableIdCom) {
        _tableIdCom = _tableland.createTable(
            address(this),
            string.concat(
                "CREATE TABLE ",
                "TrustedSphereCom",
                "_",
                Strings.toString(block.chainid),
                " (idCom int primary key, ComName text, City text, Country text, ComAddress1 text,",
                " Gps text, Units int, Fee int, ContractWallet text, AdminWallet text, Status int);"
            )
        );

        tableNameCom = string.concat(
            "TrustedSphereCom",
            "_",
            Strings.toString(block.chainid),
            "_",
            Strings.toString(_tableIdCom)
        );
    } */

    //Add a new community to DB
    /*     function addCommunity(
        string memory _comName,
        string memory _city,
        string memory _country,
        string memory _addr,
        string memory _gps,
        uint256 _units,
        uint256 _fee,
        address _adminWallet
    ) external payable {
        _tableland.runSQL(
            address(this),
            _tableIdCom,
            string.concat(
                "INSERT INTO ",
                tableNameCom,
                " (idCom, ComName, City, Country, ComAddress1, Gps, Units, Fee, ContractWallet, AdminWallet, Status) VALUES (",
                Strings.toString(_counterCom),
                ", '",
                _comName,
                "', '",
                _city,
                "', '",
                _country,
                "', '",
                _addr,
                "', '",
                _gps,
                "', ",
                Strings.toString(_units),
                ", ",
                Strings.toString(_fee),
                ", '', '",
                Strings.toHexString(uint256(uint160(_adminWallet)), 20),
                "', 1)"
            )
        );
        address _contractWallet = generateChild(_counterCom);

        // Update DB to register the contract address of the new community
        _tableland.runSQL(
            address(this),
            _tableIdCom,
            string.concat(
                "UPDATE ",
                tableNameCom,
                " SET contractWallet='",
                Strings.toHexString(uint256(uint160(_contractWallet)), 20),
                "' WHERE idCom=",
                Strings.toString(_counterCom)
            )
        );
        _counterCom++;
    } */

    //Generate new contract to the new community
    function generateChild(uint256 _community) public returns (address) {
        Child comm = new Child(_community, address(this));
        communitiesInContract.push(comm);
        comm.transferOwnership(msg.sender);
        emit ChildCreated(address(comm));
        return address(comm);
    }

    // Function to retire any ERC20 from contract, to be used only by the owner.
    function retireFunds(address _destination, address _stableAddress)
        public
        onlyOwner
    {
        uint256 amount = IERC20(_stableAddress).balanceOf(address(this));
        IERC20(_stableAddress).transfer(_destination, amount);
    }
}

/*******************************************************
/ OBSERVACIONES
/ Tenemos que hacer que al crear el contrato o hacer el deploy se ejecute
/ la funcion de createTableCom() lo intente en el constructor pero no se puede
/ igual se hace manual, pero por si acaso hay alguna otra forma
*/
