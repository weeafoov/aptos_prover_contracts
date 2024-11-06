spec bank_apt::bank {
    spec deposit {
        // pragma aborts_if_is_strict;
        aborts_if amount == 0;
        aborts_if !exists<coin::CoinStore<AptosCoin>>(signer::address_of(to));
        aborts_if global<coin::CoinStore<Coin<AptosCoin>>>(signer::address_of(to)).coin.value < amount ; // precondition required by deposit-not-revert  
        // deposit-revert-if-low-eth: a deposit call reverts if amount is greater than the APT balance of the signer.
        aborts_if !coin::spec_is_account_registered<coin::CoinStore<AptosCoin>>(signer::address_of(to));
        aborts_if !coin::is_coin_initialized<coin::CoinStore<AptosCoin>>();
        aborts_if global<coin::CoinStore<AptosCoin>>(signer::address_of(to)).frozen;
        // ensures global<coin::CoinStore<AptosCoin>>(signer::address_of(client)).coin.value == (old(global<coin::CoinStore<AptosCoin>>(signer::address_of(client))).coin.value - amount);//
        let clients = global<Bank>(bank).clients;
        let post clients_post = global<Bank>(bank).clients;
        ensures simple_map::spec_contains_key(clients,signer::address_of(to)) 
            ==> (simple_map::spec_get(clients_post,signer::address_of(to)).value == 
            simple_map::spec_get(clients,signer::address_of(to)).value + amount);//(1)
        ensures !simple_map::spec_contains_key(clients,signer::address_of(to)) 
            ==> (simple_map::spec_get(clients_post,signer::address_of(to)).value == amount);//(2)
        // deposit-contract-balance: after a successful deposit(), the ETH balance of the contract is increased by msg.value.(1: exists a client already in the clients map, 2: there is no client in clients map)
        // deposit-not-revert: I do belive that is not provable in Move aptos 
        // unless the additional condition is added: 
        // amount of coins in clients[to] < MAX_U64 + deposit
        // otherwise there is the possibility of overflow
        ensures forall c: address where c != signer::address_of(to) && simple_map::spec_contains_key(clients,c):
            simple_map::spec_get(clients_post,c).value == simple_map::spec_get(clients,c).value; // no other client account is modified, similar to 
        // user-balance-dec-onlyif-withdraw: the only way to decrease the balance entry of a user a is by calling withdraw with msg.sender = a. (since there is no possibility AFAIK
        // to define properties over functions in aptos move prover)

    }

    spec withdraw {
        // pragma verify = false;
        // pragma aborts_if_is_partial; // TODO: unable to prove more complex condition 
        // related to transfer of coin
        aborts_if amount == 0;
// withdraw-revert: a withdraw(amount) call reverts if amount is zero or greater than the balance entry of msg.sender. 
        aborts_if !exists<Bank>(bank);
        // aborts_if !exists<coin::CoinInfo<coin::CoinStore<AptosCoin>>>(signer::address_of(client));
        aborts_if !coin::spec_is_account_registered<coin::CoinStore<AptosCoin>>(signer::address_of(client));
        aborts_if !coin::is_coin_initialized<coin::CoinStore<AptosCoin>>();
        aborts_if global<coin::CoinStore<AptosCoin>>(signer::address_of(client)).frozen;
        let clients = global<Bank>(bank).clients;
        aborts_if !simple_map::spec_contains_key(clients, signer::address_of(client));
        let client_bank_money = simple_map::spec_get(clients,signer::address_of(client)).value;
        let post client_bank_money_post =  simple_map::spec_get(clients,signer::address_of(client)).value;
        // aborts_if !coin::spec_is_account_registered<coin::CoinStore<AptosCoin>>(signer::address_of(client));
        aborts_if client_bank_money < amount; //  withdraw-revert: a withdraw(amount) call reverts if amount is zero or greater than the balance entry of msg.sender.
        aborts_if global<coin::CoinStore<AptosCoin>>(signer::address_of(client)).coin.value + amount > MAX_U64 ;
        ensures global<coin::CoinStore<AptosCoin>>(signer::address_of(client)).coin.value == (old(global<coin::CoinStore<AptosCoin>>(signer::address_of(client))).coin.value + amount);
        // withdraw-sender-rcv: after a successful withdraw(amount), the ETH balance of the transaction sender is increased by amount ETH.
        ensures client_bank_money_post == client_bank_money - amount; 
        // withdraw-contract-balance: after a successful withdraw(amount), the ETH balance the contract is decreased by amount

        // ensures forall c:address where c != to && simple_map::spec_contains_key(clients,c)
            // ==> simple_map::spec_get(clients_post,c).value == simple_map::spec_get(clients.c).value; // no other client account is modified
    }
}
