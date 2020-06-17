import React from "react";
import ReactDOM from "react-dom";
import "./styles.css";

class GameContainer extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      grid: null,
      score: 0,
      gameOver: false,
      message: null
    };
  }

  generateGrid() {
    let grid = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];
    grid = this.randomTile(this.randomTile(grid));
    this.setState({ grid, score: 0, gameOver: false, message: null });
  }

  getCellCoordinates(grid) {
    const tileLocations = [];

    for (let r = 0; r < grid.length; r++) {
      for (let c = 0; c < grid[r].length; c++) {
        if (grid[r][c] === 0) {
          tileLocations.push([r, c]);
        }
      }
    }

    return tileLocations;
  }

  randomStart() {
    const startingNumbers = [2, 4];
    const randomNumber =
      startingNumbers[Math.floor(Math.random() * startingNumbers.length)];
    return randomNumber;
  }

  randomTile(grid) {
    const tileLocations = this.getCellCoordinates(grid);
    const randomCoordinate =
      tileLocations[Math.floor(Math.random() * tileLocations.length)];
    const randomNumber = this.randomStart();
    grid[randomCoordinate[0]][randomCoordinate[1]] = randomNumber;
    return grid;
  }

  gridMoved(after, before) {
    return JSON.stringify(before) !== JSON.stringify(after) ? true : false;
  }

  move(direction) {
    if (!this.state.gameOver) {
      if (direction === "up") {
        const movedUp = this.moveUp(this.state.grid);
        if (this.gridMoved(this.state.grid, movedUp.grid)) {
          const randomlyUp = this.randomTile(movedUp.grid);

          if (this.checkForGameOver(randomlyUp)) {
            this.setState({
              grid: randomlyUp,
              gameOver: true,
              message: "Game over!"
            });
          } else {
            this.setState({
              grid: randomlyUp,
              score: (this.state.score += movedUp.score)
            });
          }
        }
      } else if (direction === "right") {
        const movedRight = this.moveRight(this.state.grid);
        if (this.gridMoved(this.state.grid, movedRight.grid)) {
          const randomlyRight = this.randomTile(movedRight.grid);

          if (this.checkForGameOver(randomlyRight)) {
            this.setState({
              grid: randomlyRight,
              gameOver: true,
              message: "Game over!"
            });
          } else {
            this.setState({
              grid: randomlyRight,
              score: (this.state.score += movedRight.score)
            });
          }
        }
      } else if (direction === "down") {
        const movedDown = this.moveDown(this.state.grid);
        if (this.gridMoved(this.state.grid, movedDown.grid)) {
          const randomlyDown = this.randomTile(movedDown.grid);

          if (this.checkForGameOver(randomlyDown)) {
            this.setState({
              grid: randomlyDown,
              gameOver: true,
              message: "Game over!"
            });
          } else {
            this.setState({
              grid: randomlyDown,
              score: (this.state.score += movedDown.score)
            });
          }
        }
      } else if (direction === "left") {
        const movedLeft = this.moveLeft(this.state.grid);
        if (this.gridMoved(this.state.grid, movedLeft.grid)) {
          const randomlyLeft = this.randomTile(movedLeft.grid);

          if (this.checkForGameOver(randomlyLeft)) {
            this.setState({
              grid: randomlyLeft,
              gameOver: true,
              message: "Game over!"
            });
          } else {
            this.setState({
              grid: randomlyLeft,
              score: (this.state.score += movedLeft.score)
            });
          }
        }
      }
    } else {
      this.setState({ message: "Game over!" });
    }
  }

  moveUp(passGrid) {
    let flipedRight = this.flipRight(passGrid);
    let grid = [];
    let score = 0;

    for (let r = 0; r < flipedRight.length; r++) {
      let row = [];
      for (let c = 0; c < flipedRight[r].length; c++) {
        let current = flipedRight[r][c];
        current === 0 ? row.unshift(current) : row.push(current);
      }
      grid.push(row);
    }

    for (let r = 0; r < grid.length; r++) {
      for (let c = grid[r].length - 1; c >= 0; c--) {
        if (grid[r][c] > 0 && grid[r][c] === grid[r][c - 1]) {
          grid[r][c] = grid[r][c] * 2;
          grid[r][c - 1] = 0;
          score += grid[r][c];
        } else if (grid[r][c] === 0 && grid[r][c - 1] > 0) {
          grid[r][c] = grid[r][c - 1];
          grid[r][c - 1] = 0;
        }
      }
    }

    grid = this.flipLeft(grid);

    return { grid, score };
  }

  moveRight(passGrid) {
    let grid = [];
    let score = 0;

    for (let r = 0; r < passGrid.length; r++) {
      let row = [];
      for (let c = 0; c < passGrid[r].length; c++) {
        let current = passGrid[r][c];
        current === 0 ? row.unshift(current) : row.push(current);
      }
      grid.push(row);
    }

    for (let r = 0; r < grid.length; r++) {
      for (let c = grid[r].length - 1; c >= 0; c--) {
        if (grid[r][c] > 0 && grid[r][c] === grid[r][c - 1]) {
          grid[r][c] = grid[r][c] * 2;
          grid[r][c - 1] = 0;
          score += grid[r][c];
        } else if (grid[r][c] === 0 && grid[r][c - 1] > 0) {
          grid[r][c] = grid[r][c - 1];
          grid[r][c - 1] = 0;
        }
      }
    }

    return { grid, score };
  }

  moveDown(passGrid) {
    let flipedRight = this.flipRight(passGrid);
    let grid = [];
    let score = 0;

    for (let r = 0; r < flipedRight.length; r++) {
      let row = [];
      for (let c = flipedRight[r].length - 1; c >= 0; c--) {
        let current = flipedRight[r][c];
        current === 0 ? row.push(current) : row.unshift(current);
      }
      grid.push(row);
    }

    for (let r = 0; r < grid.length; r++) {
      for (let c = 0; c < grid.length; c++) {
        if (grid[r][c] > 0 && grid[r][c] === grid[r][c + 1]) {
          grid[r][c] = grid[r][c] * 2;
          grid[r][c + 1] = 0;
          score += grid[r][c];
        } else if (grid[r][c] === 0 && grid[r][c + 1] > 0) {
          grid[r][c] = grid[r][c + 1];
          grid[r][c + 1] = 0;
        }
      }
    }

    grid = this.flipLeft(grid);

    return { grid, score };
  }

  moveLeft(passGrid) {
    let grid = [];
    let score = 0;

    for (let r = 0; r < passGrid.length; r++) {
      let row = [];
      for (let c = passGrid[r].length - 1; c >= 0; c--) {
        let current = passGrid[r][c];
        current === 0 ? row.push(current) : row.unshift(current);
      }
      grid.push(row);
    }

    for (let r = 0; r < grid.length; r++) {
      for (let c = 0; c < grid.length; c++) {
        if (grid[r][c] > 0 && grid[r][c] === grid[r][c + 1]) {
          grid[r][c] = grid[r][c] * 2;
          grid[r][c + 1] = 0;
          score += grid[r][c];
        } else if (grid[r][c] === 0 && grid[r][c + 1] > 0) {
          grid[r][c] = grid[r][c + 1];
          grid[r][c + 1] = 0;
        }
      }
    }

    return { grid, score };
  }

  flipRight(matrix) {
    let result = [];

    for (let c = 0; c < matrix.length; c++) {
      let row = [];
      for (let r = matrix.length - 1; r >= 0; r--) {
        row.push(matrix[r][c]);
      }
      result.push(row);
    }

    return result;
  }

  flipLeft(matrix) {
    let result = [];

    for (let c = matrix.length - 1; c >= 0; c--) {
      let row = [];
      for (let r = matrix.length - 1; r >= 0; r--) {
        row.unshift(matrix[r][c]);
      }
      result.push(row);
    }

    return result;
  }

  checkForGameOver(grid) {
    let moves = [
      this.gridMoved(grid, this.moveUp(grid).grid),
      this.gridMoved(grid, this.moveRight(grid).grid),
      this.gridMoved(grid, this.moveDown(grid).grid),
      this.gridMoved(grid, this.moveLeft(grid).grid)
    ];

    return moves.includes(true) ? false : true;
  }

  componentWillMount() {
    this.generateGrid();
    const body = document.querySelector("body");
    body.addEventListener("keydown", this.handleKeyDown.bind(this));
  }

  handleKeyDown(e) {
    const up = 38;
    const right = 39;
    const down = 40;
    const left = 37;
    const n = 78;

    if (e.keyCode === up) {
      e.preventDefault();
      this.move("up");
    } else if (e.keyCode === right) {
      e.preventDefault();
      this.move("right");
    } else if (e.keyCode === down) {
      e.preventDefault();
      this.move("down");
    } else if (e.keyCode === left) {
      e.preventDefault();
      this.move("left");
    } else if (e.keyCode === n) {
      e.preventDefault();
      this.generateGrid();
    }
  }

  render() {
    if (this.state.message !== null) {
      var table = document.getElementsByTagName("table")[0];
      table.setAttribute("class", "gameover");
      var msg = (
        <div className="gameovermsg">
          {this.state.message}
          <div
            id="tryagain"
            onClick={() => {
              this.generateGrid();
              table.removeAttribute("class");
            }}
          >
            Try again
          </div>
        </div>
      );
    }
    return (
      <div>
        {msg}
        <div id="gamecontainer">
          <div className="gameheader">
            <div className="score">Score: {this.state.score}</div>
            <h1>2048</h1>
          </div>

          <div className="gameheader2">
            <p className="aim">
              Join the numbers and get to the <strong>2048 tile!</strong>
            </p>
            <div
              className="button"
              onClick={() => {
                this.generateGrid();
                table.removeAttribute("class");
              }}
            >
              New Game
            </div>
          </div>

          <table>
            {this.state.grid.map((row, i) => (
              <Row key={i} row={row} />
            ))}
          </table>

          <div className="help">
            HOW TO PLAY: Use your <strong>arrow keys</strong> to move the tiles.
            When two tiles with the same number touch, they{" "}
            <strong>merge into one!</strong>
          </div>
          <hr />
          <footer>ieee task clone of 2048 by saurabh gole</footer>
        </div>
      </div>
    );
  }
}

const Row = ({ row }) => {
  return (
    <tr>
      {row.map((tile, i) => (
        <Tile key={i} tileValue={tile} />
      ))}
    </tr>
  );
};

const Tile = ({ tileValue }) => {
  let color = "tile";
  let value = tileValue === 0 ? "" : tileValue;
  if (value) {
    color += ` color-${value}`;
  }

  return (
    <td>
      <div className={color}>
        <div className="number">{value}</div>
      </div>
    </td>
  );
};

ReactDOM.render(<GameContainer />, document.getElementById("root"));
