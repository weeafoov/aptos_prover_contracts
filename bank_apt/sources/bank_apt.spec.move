spec bank_apt::bank {
    spec deposit {
        // pragma aborts_if_is_strict;
        // aborts_if amount == 0;
        // aborts_if !exists<coin::CoinStore<AptosCoin>>(signer::address_of(to));
        // aborts_if global<coin::CoinStore<Coin<AptosCoin>>>(signer::address_of(to)).coin.value < amount ;
        // modifies global<coin::CoinStore<AptosCoin>>(signer::address_of(to));
        // aborts_if global<coin::CoinStore<AptosCoin>>(signer::address_of(to)).coin.value < amount;
}

    spec withdraw {
        aborts_if amount == 0;
        aborts_if !exists<Bank>(signer::address_of(bank));
        let clients = global<Bank>(signer::address_of(bank)).clients;
        aborts_if !simple_map::spec_contains_key(clients, signer::address_of(client));
        let client_bank_money = simple_map::spec_get(clients,signer::address_of(client)).value;
        aborts_if client_bank_money < amount;
        // let client_coin_store = global<coin::CoinStore<AptosCoin>>(signer::address_of(client));
        // aborts_if client_coin_store.frozen;
        // aborts_if !exists<coin::CoinStore<AptosCoin>>(signer::address_of(client));
        // let value_coin_in_address = global<coin::CoinStore<AptosCoin>>(signer::address_of(client)).coin.value;
    }
}
