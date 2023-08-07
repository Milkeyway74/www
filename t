class InfoMessage:
    """Информационное сообщение о тренировке."""
    def __init__(self,
                 training_type: str,
                 duration: float,
                 distance: float,
                 speed: float,
                 calories: float):
        self.training_type = training_type
        self.duration = duration
        self.distance = distance
        self.speed = speed
        self.calories = calories

    def get_message(self) -> str:
        return (f'Тип тренировки: {self.training_type};'
                f' Длительность: {self.duration:.3f} ч.;'
                f' Дистанция: {self.distance:.3f} км;'
                f' Ср. скорость: {self.speed:.3f} км/ч;'
                f'Потрачено ккал: {self.calories:.3f}. ')


class Training:
    LEN_STEP: float = 0.65
    M_IN_KM: int = 1000
    M_IN_HOUR: int = 60
    """Базовый класс тренировки."""
    def __init__(self,
                 action: int,
                 duration: float,
                 weight: float,
                 ) -> None:
        self.action = action
        self.duration = duration
        self.weight = weight

    def get_distance(self) -> float:
        """Получить дистанцию в км."""
        dist = self.action * self.LEN_STEP / self.M_IN_KM
        return dist

    def get_mean_speed(self) -> float:
        """Получить среднюю скорость движения."""
        dist = self.get_distance()
        mean_speed = dist / self.duration
        return mean_speed

    def get_spent_calories(self) -> float:
        """Получить количество затраченных калорий."""
        pass

    def show_training_info(self) -> InfoMessage:
        """Вернуть информационное сообщение о выполненной тренировке."""
        training_type = self.__class__.__name__
        distance = self.get_distance()
        speed = self.get_mean_speed()
        calories = self.get_spent_calories()
        return InfoMessage(training_type, self.duration, distance, speed,
                           calories)


class Running(Training):
    """Тренировка: бег."""
    CALORIES_MEAN_SPEED_MULTIPLIER: int = 18
    CALORIES_MEAN_SPEED_SHIFT: float = 1.79
    M_IN_KM = 1000
    TIME_IN_MIN = 60
    MIN_IN_HOUR = 60

    def __init__(self, action, duration, weight):
        super().__init__(action, duration, weight)

    def get_spent_calories(self) -> float:
        calories = ((self.CALORIES_MEAN_SPEED_MULTIPLIER
                     * super().get_mean_speed()
                     + self.CALORIES_MEAN_SPEED_SHIFT)
                    * self.weight / self.M_IN_KM * self.duration
                    * self.MIN_IN_HOUR)
        return calories


class SportsWalking(Training):
    WEIGHT_MULTIPLIER_1 = 0.035
    WEIGHT_MULTIPLIER_2 = 0.029
    SM_IN_M = 100
    KMH_IN_MS = 1 / 3.6
    """Тренировка: спортивная ходьба."""
    def __init__(self, action, duration, weight, height):
        self.height = height
        super().__init__(action, duration, weight)

    def get_spent_calories(self):
        duration_in_min = self.duration * super().M_IN_HOUR
        MEAN_SPEED_IN_MS = self.get_mean_speed() * self.KMH_IN_MS
        calories = ((self.WEIGHT_MULTIPLIER_1 * self.weight
                     + (MEAN_SPEED_IN_MS**2 / self.height)
                     * self.WEIGHT_MULTIPLIER_2 * self.weight)
                    * duration_in_min)
        return calories

    def get_mean_speed(self) -> float:
        mean_speed = self.action * super().LEN_STEP / super().M_IN_KM
        return mean_speed


class Swimming(Training):
    """Тренировка: плавание."""
    LEN_STEP: float = 1.38
    MEAN_SPEED_SHIFT: float = 1.1
    MEAN_SPEED_MULTIPLIER: int = 2

    def __init__(self, action, duration, weight, length_pool, count_pool):
        self.length_pool = length_pool
        self.count_pool = count_pool
        super().__init__(action, duration, weight)

    def get_distance(self) -> float:
        """Получить дистанцию в км."""
        dist = self.action * self.LEN_STEP / super().M_IN_KM
        return dist

    def get_mean_speed(self) -> float:
        mean_speed = (self.length_pool * self.count_pool
                      / super().M_IN_KM / self.duration)
        return mean_speed

    def get_spent_calories(self) -> float:
        calories = ((self.get_mean_speed() + self.MEAN_SPEED_SHIFT)
                    * self.MEAN_SPEED_MULTIPLIER
                    * self.weight * self.duration)
        return calories


def read_package(workout_type: str, data: list) -> Training:
    """Прочитать данные полученные от датчиков."""
    DICT = {'SWM': Swimming, 'RUN': Running, 'WLK': SportsWalking}
    param = DICT.get(workout_type)
    if param:
        return param(*data)
    else:
        print('Тут что-то не так')


def main(training: Training) -> None:
    """Главная функция."""
    info = training.show_training_info()
    info = info.get_message()
    print(info)


if __name__ == '__main__':
    packages = [
        ('SWM', [720, 1, 80, 25, 40]),
        ('RUN', [15000, 1, 75]),
        ('WLK', [9000, 1, 75, 180]),
    ]

    for workout_type, data in packages:
        try:
            training = read_package(workout_type, data)
        except IndexError():
            print('Ошибка')
        training.main()
