## Objective

## Vending Machine

- Once an item is selected and the appropriate amount of money is inserted, the vending machine should return the correct product.
- It should also return change if too much money is provided, or ask for more money if insufficient funds have been inserted.
- The machine should take an initial load of products and change. The change will be of denominations 1p, 2p, 5p, 10p, 20p, 50p, £1, £2.
- There should be a way of reloading either products or change at a later point.
- The machine should keep track of the products and change that it contains.

## How to run the app
1. Open a terminal
2. cd to root directory
3. `bundle install` ( probably you might have to install first the bundler by running: `gem install bundler` )
4. Then you can run the app by running the executable and specifying the customers text file location
e.g. `./bin/vending_machine`

## Run the tests
 The App is provided with some tests whose purpose is to prove the correctness of the App and find any possible
  breakage of the existing code in future alteration of the app.
To Run the rspec tests you can run

`bundle exec rspec`


Antonis Berkakis
