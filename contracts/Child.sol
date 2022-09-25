// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
//import "@tableland/contracts/TablelandTables.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

//imports agregados
import "@openzeppelin/contracts/access/Ownable.sol";
import "./NFTContract.sol";
import "@aave/contracts/interfaces/IPool.sol";
import "@aave/contracts/interfaces/IPoolAddressesProvider.sol";
import "@aave/contracts/interfaces/IAToken.sol";

contract Child is ERC721Holder, Ownable {
    mapping(address => uint256) public Units;
    mapping(uint256 => address) Supliers;
    address admin; //Administrador de la comunidad
    uint256 community; //Id de Comunidad **** Como la hacemos constante??
    address MasterContract; //address del contrato padre, siempre constante
    // address del contrato de mumbai polygon, debe ser variable para cambiarlo faciul de red, pero por lo pronto asi esta mas facil
    address _registry = 0x4b48841d4b32C4650E4ABc117A03FE8B51f38F68; //Polygon Mumbai

    address fatherContract;
    NFTContract paymentReceipt;

    //ITablelandTables internal _tableland;
    // Variables Tabla Units(Casas)
    string public tableNameUnit;
    uint256 internal _tableIdUnit;
    uint256 internal counterUnit;
    // Variables Tabla Payments
    string public tableNamePay;
    uint256 internal _tableIdPay;
    uint256 internal counterPay;
    // Variables Tabla Suppliers
    string public tableNameSup;
    uint256 internal _tableIdSup;
    uint256 internal counterSup;
    // Variables Tabla Suppliers Payments
    string public tableNameSP;
    uint256 internal _tableIdSP;
    uint256 internal counterSP;

    //Variables aave
    //The address of the stablecoin to use
    address public stableAddress;

    //The aToken produced when you deposit the stablecoin
    IAToken public aTokenContract;

    //aave pool interface
    IPool public aavePool;

    //Balance of stable token in contract
    uint256 public contractBalance;

    //Maps address to stable amount deposited to contract
    mapping(address => uint256) public depositedAmount;

    constructor(uint256 _community, address _masterContract) {
        community = _community;
        MasterContract = _masterContract;
        /* _tableland = ITablelandTables(_registry); */
        fatherContract = msg.sender;

        counterPay = 1;
        counterSup = 1;
        counterSP = 1;
        counterUnit = 1;

        // Aave hardcoded
        aavePool = IPool(0xf368fF03831Accc37BEe8461523560f06918faEd);
        aTokenContract = IAToken(0x1E7DEb5E5b6D92D8C51312C15Fa50d9b8AE76F1A);
        stableAddress = 0x7b4Bf48b219765392A839D6a47178A3633d412a0;
    }

    function deployNFTs() public onlyOwner {
        paymentReceipt = new NFTContract();
    }

    // Verifica que sea miembro de la comunidad
    modifier requireMember() {
        bool isMember = false;
        uint256 unit;

        unit = Units[msg.sender];
        if (unit != 0) isMember = true;

        require(isMember, "Tu Wallet no esta dada de alta en esta comunidad");
        _;
    }

    // Verifica que no se haya creado la tabla
    modifier tableExist(uint256 idtable) {
        bool exist = false;

        if (idtable != 0) exist = true;

        require(!exist, "Esta Tabla ya fue creada");
        _;
    }

    /*     function createTableUnit() external payable tableExist(_tableIdUnit) {
        _tableIdUnit = _tableland.createTable(
            address(this),
            string.concat(
                "CREATE TABLE ",
                "TrustedSphereUnit",
                Strings.toString(community),
                "_",
                Strings.toString(block.chainid),
                " (idUnit int primary key, idCom int, NumUnit int, NameOwner text, Status int);"
            )
        );

        tableNameUnit = string.concat(
            "TrustedSphereUnit",
            Strings.toString(community),
            "_",
            Strings.toString(block.chainid),
            "_",
            Strings.toString(_tableIdUnit)
        );
    }  */

    /*  function createTablePayments() external payable tableExist(_tableIdPay) {
        _tableIdPay = _tableland.createTable(
            address(this),
            string.concat(
                "CREATE TABLE ",
                "TrustedSpherePay",
                Strings.toString(community),
                "_",
                Strings.toString(block.chainid),
                " (idPay int primary key, idUnit int, Fee int, Year int, Month int, date text, Status int);"
            )
        );

        tableNamePay = string.concat(
            "TrustedSpherePay",
            Strings.toString(community),
            "_",
            Strings.toString(block.chainid),
            "_",
            Strings.toString(_tableIdPay)
        );
    } */

    /* function createTableSuppliers() external payable tableExist(_tableIdSup) {
        _tableIdSup = _tableland.createTable(
            address(this),
            string.concat(
                "CREATE TABLE ",
                "TrustedSphereSup",
                Strings.toString(community),
                "_",
                Strings.toString(block.chainid),
                " (idSup int primary key, idCom int, SupName text, amount int, day int, status int);"
            )
        );

        tableNameSup = string.concat(
            "TrustedSphereSup",
            Strings.toString(community),
            "_",
            Strings.toString(block.chainid),
            "_",
            Strings.toString(_tableIdSup)
        );
    } */

    /*
     */

    //Add a new unit to de DB and the mapping "Units"
    function addUnit(
        uint256 _num,
        string memory _name,
        address _ownerW
    ) external payable {
        Units[msg.sender] = _num;

        /* _tableland.runSQL(
            address(this), //revisar si es esta address o tienes que ser la del padre
            _tableIdUnit,
            string.concat(
                "INSERT INTO ",
                tableNameUnit,
                " (idunit, idcom, numunit, nameowner, status) VALUES (",
                Strings.toString(counterUnit),
                ", ",
                Strings.toString(community),
                ", ",
                Strings.toString(_num),
                ", '",
                _name,
                "', 1)"
            )
        ); */
        counterUnit++;
    }

    function depositt(
        uint256 _fee,
        uint256 _unit,
        uint256 _month,
        uint256 _year
    ) public {
        require(
            IERC20(stableAddress).allowance(msg.sender, address(this)) >= _fee,
            "needs approval"
        );
        IERC20(stableAddress).transferFrom(msg.sender, address(this), _fee);
        depositedAmount[msg.sender] = _fee;
        contractBalance += _fee;
        //Save to DB
        /*  _tableland.runSQL(
            address(this),
            _tableIdPay,
            string.concat(
                "INSERT INTO ",
                tableNamePay,
                " (idPay, idUnit, Fee, Year, Month, date, status) VALUES (",
                Strings.toString(counterPay),
                ", ",
                Strings.toString(_unit),
                ", ",
                Strings.toString(_fee),
                ", ",
                Strings.toString(_year),
                ", ",
                Strings.toString(_month),
                ", ",
                Strings.toString(block.timestamp),
                ", 1)"
            )
        ); */
        //counterPay++;

        paymentReceipt.createCollectible(msg.sender);
    }

    // This function have to be from frontend with the tableland API
    /*function getLastMonth(address _user) view returns (uint, uint) {
    }*/

    function addSuplier(
        string memory _name,
        uint256 _amount,
        address _supWallet,
        uint256 _day
    ) external payable {
        Supliers[counterSup] = _supWallet;

        //Save to DB
        /* _tableland.runSQL(
            address(this),
            _tableIdSup,
            string.concat(
                "INSERT INTO ",
                tableNameSup,
                " (idSup, idCom, SupName, amount, day, status) VALUES (",
                Strings.toString(counterSup),
                ", ",
                Strings.toString(community),
                ", '",
                _name,
                "', ",
                Strings.toString(_amount),
                ", ",
                Strings.toString(_day),
                ", 1)"
            )
        ); */
        counterSup++;
    }

    //returns the contract balance (community balance)
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function suplierPayme(
        uint256 _idSup,
        uint256 _amount,
        uint256 _year,
        uint256 _month
    ) external onlyOwner {
        require(address(this).balance > _amount, "Not enough money!!");

        address supWallet = Supliers[_idSup];

        (bool resultado, bytes memory salida) = supWallet.call{value: _amount}(
            ""
        );
        require(resultado, "nos fallo esta madre");

        //Save to DB
        /* _tableland.runSQL(
            address(this),
            _tableIdSP,
            string.concat(
                "INSERT INTO ",
                tableNameSP,
                " (idSP, idSup, amount, year, month, date, status) VALUES (",
                Strings.toString(counterSP),
                ", ",
                Strings.toString(_idSup),
                ", ",
                Strings.toString(_amount),
                ", ",
                Strings.toString(_year),
                ", ",
                Strings.toString(_month),
                ", '",
                Strings.toString(block.timestamp),
                "', 1)"
            )
        ); */
        counterSP++;
    }

    //Regresa la Unit del usuario que ingreso a la dapp, si es 0 no esta dado de alta
    function getUnit() public view returns (uint256) {
        return Units[msg.sender];
    }

    // Funcionalidades AAVE
    /**
        @dev Lets contract owner deposit _amount to aave pool

        Requirements:
            - '_amount" has to be smaller or equal to tha amount of ERC20
            the contract has
     */

    function supplyToPool(uint256 _amount) public onlyOwner {
        require(_amount <= contractBalance, "Insufficient funds in contract");
        IERC20(stableAddress).approve(address(aavePool), _amount);
        aavePool.supply(stableAddress, _amount, address(this), 0);
        contractBalance -= _amount;
    }

    /**
        @dev Lets contract owner withdraw '_amount' from pool

        Requirements:
            - '_amount' has to be lees or equal to the amount previously 
            deposited. 
     */
    function withdrawFromPool(uint256 _amount) public onlyOwner {
        require(
            _amount <= aTokenContract.balanceOf(address(this)),
            "Insufficient aTokens"
        );
        //Quita lo siguiente
        //aTokenContract.approve(address(aavePool), _amount);
        aavePool.withdraw(stableAddress, _amount, address(this));
        //Manda a padre fee por uso de infraestructura (1%)
        IERC20(stableAddress).transfer(fatherContract, _amount / 100);
        contractBalance += (_amount / 100) * 99;
    }
}

/******************************************************************************************
  ACLARACIONES 
  No se esta revisando todavia duplicados en numero de units, wallets, supplieres, etc...
  */
