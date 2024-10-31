spec bank_apt::bank {
    // spec deposit {
        // pragma aborts_if_is_strict;
        // aborts_if amount == 0;
        // aborts_if !exists<coin::CoinStore<AptosCoin>>(signer::address_of(to));
        // aborts_if global<coin::CoinStore<Coin<AptosCoin>>>(signer::address_of(to)).coin.value < amount ;
        // modifies global<coin::CoinStore<AptosCoin>>(signer::address_of(to));
        // aborts_if global<coin::CoinStore<AptosCoin>>(signer::address_of(to)).coin.value < amount;
        // }

    spec withdraw {
        pragma aborts_if_is_strict;
        aborts_if amount == 0;
        aborts_if !exists<Bank>(signer::address_of(bank));
        let coin_value = borrow_global<coin::CoinStore<AptosCoin>>(signer::address_of(client)).coin.value;
        aborts_if coin_value < amount;
    }
}
