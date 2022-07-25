To get started:

```
cd $HOME
git clone https://github.com/kees/workshop-gosst.git workshop
cd workshop
```

Prepare environment, which expects to live in $HOME/workshop:

```
./setup.sh
```

Rebuild Kees's patched Linux:

```
./make-linux.sh
```

Rebuild LLVM:

```
./make-llvm.sh
```

Boot Linux in emulator:

```
./boot-linux.sh
```

Rebuild Linux from Linus's tree:

```
./make-linux.sh linux
```
