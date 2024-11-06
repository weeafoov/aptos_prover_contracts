spec bank_apt::bank {
    spec deposit {
        pragma aborts_if_is_strict;
        aborts_if amount == 0;
        aborts_if !exists<coin::CoinStore<AptosCoin>>(signer::address_of(to));
        aborts_if global<coin::CoinStore<Coin<AptosCoin>>>(signer::address_of(to)).coin.value < amount ;
        // modifies global<coin::CoinStore<AptosCoin>>(signer::address_of(to));  
        ensures global<coin::CoinStore<AptosCoin>>(signer::address_of(client)).coin.value == (old(global<coin::CoinStore<AptosCoin>>(signer::address_of(client))).coin.value - amount);

    }

    spec withdraw {
        // pragma verify = false;
        // pragma aborts_if_is_partial; // TODO: unable to prove more complex condition 
        // related to transfer of coin
        aborts_if amount == 0;
        aborts_if !exists<Bank>(bank);
        // aborts_if !exists<coin::CoinInfo<coin::CoinStore<AptosCoin>>>(signer::address_of(client));
        aborts_if !coin::spec_is_account_registered<coin::CoinStore<AptosCoin>>(signer::address_of(client));
        aborts_if !coin::is_coin_initialized<coin::CoinStore<AptosCoin>>();
        aborts_if global<coin::CoinStore<AptosCoin>>(signer::address_of(client)).frozen;
        let clients = global<Bank>(bank).clients;
        aborts_if !simple_map::spec_contains_key(clients, signer::address_of(client));
        let client_bank_money = simple_map::spec_get(clients,signer::address_of(client)).value;
        // aborts_if !coin::spec_is_account_registered<coin::CoinStore<AptosCoin>>(signer::address_of(client));
        aborts_if client_bank_money < amount;
        aborts_if global<coin::CoinStore<AptosCoin>>(signer::address_of(client)).coin.value + amount > MAX_U64 ;
        // ensures global<coin::CoinStore<AptosCoin>>(signer::address_of(client)).coin.value == (old(global<coin::CoinStore<AptosCoin>>(signer::address_of(client))).coin.value + amount);
    }
}
