extends Node

signal on_ball_in_pedestal(ball: Ball)
signal on_player_exit(player: Player)
signal on_pickup_ball(player: Player, ball: Ball)

signal on_look_at_ball(e: BallSpawn)
signal on_look_away_ball(e: BallSpawn)
signal on_look_at_ped(e: BallPedestal)
signal on_look_away_ped(e: BallPedestal)

static var MAX_BALLS: int = 3

func ball_in_pedestal(ball: Ball):
	on_ball_in_pedestal.emit(ball)

func player_exit(player: Player):
	on_player_exit.emit(player)

func player_pickup(player: Player, ball: Ball):
	on_pickup_ball.emit(player, ball)

func look_at_ball(e: BallSpawn):
	on_look_at_ball.emit(e)
	
func look_away_ball(e: BallSpawn):
	on_look_away_ball.emit(e)
	
func look_at_ped(e: BallPedestal):
	on_look_at_ped.emit(e)
	
func look_away_ped(e: BallPedestal):
	on_look_away_ped.emit(e)
