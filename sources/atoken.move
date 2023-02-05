address admin {

module atoken {
    use aptos_framework::coin;
    use std::signer;
    use std::string;

    struct ATN{}

    struct CoinCapabilities<phantom ATN> has key {
        mint_capability: coin::MintCapability<ATN>,
        burn_capability: coin::BurnCapability<ATN>,
        freeze_capability: coin::FreezeCapability<ATN>,
    }

    const E_NO_ADMIN: u64 = 0;
    const E_NO_CAPABILITIES: u64 = 1;
    const E_HAS_CAPABILITIES: u64 = 2;

    public entry fun init_atn(account: &signer) {
        let (burn_capability, freeze_capability,  mint_capability) = coin::initialize<ATN>(
            account,
            string::utf8(b"A-Token"),
            string::utf8(b"ATN"),
            18,
            true,
        );

        assert!(signer::address_of(account) == @admin, E_NO_ADMIN);
        assert!(!exists<CoinCapabilities<ATN>>(@admin), E_HAS_CAPABILITIES);

        move_to<CoinCapabilities<ATN>>(account, CoinCapabilities<ATN>{mint_capability, burn_capability, freeze_capability});
    }

    public fun mint(account:&signer, amount:u64): coin::Coin<ATN> acquires CoinCapabilities {
        let account_address = signer::address_of(account);
        assert!(account_address == @admin, E_NO_ADMIN);
        assert!(exists<CoinCapabilities<ATN>>(account_address), E_NO_CAPABILITIES);
        let mint_capability = &borrow_global<CoinCapabilities<ATN>>(account_address).mint_capability;
        coin::mint<ATN>(amount, mint_capability)
     }

    public fun burn(coins: coin::Coin<ATN>) acquires CoinCapabilities {
        let burn_capability = &borrow_global<CoinCapabilities<ATN>>(@admin).burn_capability;
        coin::burn<ATN>(coins, burn_capability);
    }
}
}