import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export default function game_init(root, channel) {
  ReactDOM.render(<Starter channel={channel}/>, root);
}

class Starter extends React.Component {
  constructor(props) {
    super(props);
    this.channel = props.channel;
    // Set the state of the board.
    this.state = {
      black_turn: true,
      board: []
    };
    // Attempt to join the game.
    this.channel
    .join()
    .receive("ok", resp => {
      console.log("Joined successfully!", resp);
      this.setState(resp.game);
    })
    .receive("error", resp => {
      console.log("Unable to join", resp);
    });
    // Whenever the channel updates, set the state.
    this.channel.on("update", resp => {
      this.setState(resp.game);
    });
  }

  // Call this function to restart the game.
  restart() {
    this.channel.push("restart")
    .receive("ok", resp => { this.setState(resp.game); });
  }

  // Call this function to choose a tile.
  choose(r, c) {
    this.channel
    .push("choose", {row: r, column: c})
    .receive("ok", resp => { this.setState(resp.game); });
  }

  // Render the board.
  render() {
    // Render each of the rows in the board.
    let board = _.map(this.state.board, (row, rowIndex) => {
      return <ShowRow
      key={rowIndex}
      rowIndex={rowIndex}
      root={this}
      choose={this.choose.bind(this)}
      row={row} />;
    });
    // This is the restart button.
    let restart = (
      <div className="column">
      <button onClick={this.restart.bind(this)}>Restart</button>
      </div>
    );
    // This displays the winner.
    let winner = (
      <div className="column">
      <p>The winner is {this.state.winner}!</p>
      </div>
    );
    // This displays whose turn it is.
    let turn = (
      <div className="column">
      <h4>It is now {this.state.black_turn ? "black" : "white"}'s turn.</h4>
      </div>
    );
    // Return the HTML.
    return (
      <div>
      <div className="row">
      {/* If we have no winner, display whose turn it is, otherwise show the restart button. */}
      {this.state.winner === "none" ? turn : restart}
      {/*If we have no winner, don't display anything, otherwise show who won. */}
      {this.state.winner === "none" ? null : winner}
      </div>
      {board}
      </div>
    );
  }
}

// Render a row in the board.
function ShowRow(props) {
  // Render each tile in the row.
  let renderedRow = _.map(props.row, (col, colIndex) => {
    // Return a div with a class name equal to its color.
    // If the div is clicked, indicate that the tile has been chosen.
    return (
      <div className="column" key={colIndex}>
      <div className={col.color} onClick={
        () => props.choose(props.rowIndex, colIndex)
      }/>
      </div>
    )
  });
  // Return the HTML.
  return <div className="row">{renderedRow}</div>;
}
